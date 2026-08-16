# JIT: unrolled loop re-dispatches its switch with the index folded to 0 (wrong code)

## Description

A three-iteration loop calls a method whose body is `switch (axis) { 0 => v.X, 1 => v.Y,
2 => v.Z }`. In the Tier1 code the callee is inlined and the loop is fully unrolled. Each
unrolled copy gets its own jump table, and each copy indexes that table with 0 rather than
with the copy's own index, so all three copies read component 0.

A method that asks "are all three components zero?" therefore returns `true` for a vector
whose third component is 1.

No configuration is needed. This happens on a default installation.

## Repro

One file, 71 lines, no packages.

```bash
dotnet build -c Release
dotnet bin/Release/net10.0/repro.dll
```

Expected: no output, exit code 0.

Actual:

```
WRONG round=61159: IsZero(0, 0, 1) returned true
```

Exit code 1, in 500 of 500 runs, in about 0.2 seconds each. `./repro.sh` prints the table
below; `N=100 ./repro.sh` counts.

## Affected versions

Every published .NET 10 runtime is affected. I installed all 21 of them side by side and
ran the same `net10.0` binary on each, ten runs apiece:

| runtime | wrong |
|---|---|
| 10.0.0-preview.1.25080.5 (2025-02-25) through 10.0.0-rc.2.25502.107 | 10/10 each, 9 releases |
| 10.0.0 (2025-11-11) through 10.0.11 (2026-08-11) | 10/10 each, 12 releases |
| 11.0.0-rc.1.26413.103 (daily) | 100/100 |

.NET 8 and .NET 9 are not affected. Same source retargeted, on the same machine:

| target | wrong |
|---|---|
| net8.0 (runtime 8.0.29) | 0/20 |
| net9.0 (runtime 9.0.18) | 0/20 |
| net10.0 (runtime 10.0.10) | 20/20 |

So the change landed on main between the .NET 9 release and 10.0.0-preview.1, and has been
in every 10.0 build since. I could not narrow it further from published builds: daily
builds from before preview.1 are no longer downloadable. I have not bisected the runtime
to a commit.

## The program

```csharp
internal readonly struct V3(long x, long y, long z)
{
    public readonly long X = x;
    public readonly long Y = y;
    public readonly long Z = z;

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public static long Get(V3 value, int axis) => axis switch
    {
        0 => value.X,
        1 => value.Y,
        2 => value.Z,
        _ => throw new ArgumentOutOfRangeException(nameof(axis)),
    };
}

private static bool IsZero(V3 value)
{
    for (var axis = 0; axis < 3; axis++)
    {
        if (V3.Get(value, axis) != 0)
        {
            return false;
        }
    }

    return true;
}

[MethodImpl(MethodImplOptions.NoInlining)]
private static int CountZero(V3[] values)
{
    var zero = 0;

    for (var i = 0; i < values.Length; i++)
    {
        if (IsZero(values[i]))
        {
            zero++;
        }
    }

    return zero;
}
```

`Main` fills 256 vectors -- 255 of them `(1, 0, 0)` and the last one `(0, 0, 1)` -- and
calls `CountZero` in a loop. None of them is the zero vector, so `CountZero` must always
return 0. It returns 1 after some tens of thousands of rounds.

Two details in this shape are load-bearing:

- The array holds a mixture of values. Filling it with one repeated value makes the bug
  go away.
- `CountZero` is `[MethodImpl(MethodImplOptions.NoInlining)]`. Without it the hot loop
  collapses into a single on-stack-replacement compilation of `Main` with everything
  inlined into it; `IsZero` is then never compiled on its own and the bug does not appear.

## The generated code

`DOTNET_JitDisasm='*IsZero*' DOTNET_JitDisasmDiffable=1`; the full listing, including the
two Instrumented Tier0 compilations, is in `IsZero.asm`. This is plain Tier1 code, no OSR
involved. `[rbp+0x10]`, `[rbp+0x18]` and `[rbp+0x20]` hold components 0, 1 and 2 of the
by-value struct argument.

```asm
; Assembly listing for method Program:IsZero(V3):bool (Tier1)
; Tier1 code
; optimized using Synthesized PGO

G_M000_IG02:
       xor      eax, eax                       ; axis = 0
       jne      SHORT G_M000_IG07              ; never taken: ZF is set by the xor
G_M000_IG03:
       mov      rdi, qword ptr [rbp+0x10]      ; component 0        correct
G_M000_IG04:
       test     rdi, rdi
       je       SHORT G_M000_IG11              ; zero, go to the next axis
G_M000_IG05:
       xor      eax, eax                       ; return false
...                                            ; epilogue, and the table for axis 0
G_M000_IG11:
       mov      edi, 1                         ; axis = 1
       test     edi, edi
       je       SHORT G_M000_IG15              ; not taken
G_M000_IG12:
       xor      eax, eax                       ; index for the table, expected 1
       cmp      eax, 2
       ja       SHORT G_M000_IG25
       lea      rdi, [reloc @RWD12]
       mov      edi, dword ptr [rdi+4*rax]     ; RWD12[0], expected RWD12[1]
       lea      rcx, G_M000_IG02
       add      rdi, rcx
       jmp      rdi                            ; -> G_M000_IG15
G_M000_IG15:
       mov      rdi, qword ptr [rbp+0x10]      ; component 0 again
G_M000_IG16:
       test     rdi, rdi
       jne      SHORT G_M000_IG05
G_M000_IG17:
       mov      edi, 2                         ; axis = 2
       test     edi, edi
       je       SHORT G_M000_IG22              ; not taken
G_M000_IG18:
       xor      eax, eax                       ; index for the table, expected 2
       cmp      eax, 2
       ja       SHORT G_M000_IG25
G_M000_IG19:
       mov      eax, eax
       lea      rdi, [reloc @RWD24]
       mov      edi, dword ptr [rdi+4*rax]     ; RWD24[0], expected RWD24[2]
       lea      rcx, G_M000_IG02
       add      rdi, rcx
       jmp      rdi                            ; -> G_M000_IG22
G_M000_IG22:
       mov      rdi, qword ptr [rbp+0x10]      ; component 0 again
G_M000_IG23:
       test     rdi, rdi
       sete     al                             ; "all components zero"
       movzx    rax, al

RWD00  dd  G_M000_IG03 - G_M000_IG02      ; component 0
       dd  G_M000_IG10 - G_M000_IG02      ; component 1
       dd  G_M000_IG09 - G_M000_IG02      ; component 2
RWD12  dd  G_M000_IG15 - G_M000_IG02      ; taken, loads component 0
       dd  G_M000_IG14 - G_M000_IG02
       dd  G_M000_IG13 - G_M000_IG02
RWD24  dd  G_M000_IG22 - G_M000_IG02      ; taken, loads component 0
       dd  G_M000_IG21 - G_M000_IG02
       dd  G_M000_IG20 - G_M000_IG02
```

In each unrolled copy the index exists twice: the compare in front of the table gets the
copy's own constant (`mov edi, 1`, `mov edi, 2`), while the table is indexed with `eax`,
which still holds the 0 written for the first copy. Components 1 and 2 are never read.

I cannot say which phase produces this. `JitDump` and the per-phase switches
(`JitDoCopyProp`, `JitDoValueNumber`, `JitNoUnroll` and so on) are only honoured by a
checked JIT; on a release runtime they are ignored, which I confirmed by observing that
even `DOTNET_JitMinOpts=1` changes nothing here. The shape in front of each table -- a
test of the index against 0, then the general table -- and the fact that the bug needs a
mixture of inputs both suggest something profile-driven, but that is a guess.

## Conditions

`N=100 ./repro.sh`, identical on 10.0.11 and on 11.0.0-rc.1.26413.103:

| configuration | wrong |
|---|---|
| defaults, no configuration at all | 100/100 |
| `DOTNET_TieredCompilation=0` | 0/100 |
| `DOTNET_TieredPGO=0` | 0/100 |
| `DOTNET_TC_QuickJitForLoops=0` | 0/100 |
| `DOTNET_TC_OnStackReplacement=0` | 100/100 |
| `DOTNET_JitEnablePhysicalPromotion=0` | 100/100 |
| `DOTNET_ReadyToRun=0` | 100/100 |

Windows 11 x64 on runtime 10.0.10, same source: 50/50 wrong, and 0/20 with
`DOTNET_TieredCompilation=0`.

Workaround: `DOTNET_TieredCompilation=0`.

## What is load-bearing

Reduced by removing one thing at a time and re-checking after each removal.

Required -- removing any of these makes the bug disappear:

- `[MethodImpl(MethodImplOptions.AggressiveInlining)]` on `Get`
- `[MethodImpl(MethodImplOptions.NoInlining)]` on `CountZero`
- the `switch`; a chain of `if (axis == 0) ... ` does not reproduce
- a mixture of values in the array; one repeated value does not reproduce
- at least 3 array elements; 1 or 2 do not reproduce

Not required -- the bug survives all of these:

- the size of the non-zero constant (1 works)
- `[MethodImpl(MethodImplOptions.AggressiveInlining)]` on `IsZero`
- keeping the throw in a `[MethodImpl(MethodImplOptions.NoInlining)]` helper
- `CountZero` returning a count rather than a `bool`
- `readonly struct` and the primary constructor
- passing the array as a parameter rather than reading a static field
- `Get` being static rather than an instance method
- a generic interface with static abstract members in place of the concrete struct

## Configuration

- AMD Ryzen 5 5600X, x64
- Ubuntu 24.04.4 on WSL2 (kernel 5.15.167.4), SDK 10.0.400, runtimes 10.0.10 / 10.0.11
- Windows 11 x64, SDK 10.0.302, runtime 10.0.10
- .NET 11 daily: 11.0.0-rc.1.26413.103

Not tested: arm64, macOS, NativeAOT, Mono.

## Where it came from

Reduced from a deterministic fixed-point physics library, where it produced silently wrong
results -- no crash, no exception, a different test failing on each run, and re-running the
job turning the build green.

Measured there on default settings, with the test suite pinned to two cores: 1 of 20 runs
was wrong, at a mean of 326 seconds per run. That is what this costs in ordinary code.

## Closest existing report

[dotnet/runtime#87611](https://github.com/dotnet/runtime/issues/87611), "JIT: Physical
promotion can create some writebacks too late", is the same class of defect but was fixed
in 2023 and is not this one: `DOTNET_JitEnablePhysicalPromotion=0` does not affect this
repro. I did not find an open issue that matches.
