using System.Runtime.CompilerServices;

// Wrong code on .NET 10 and .NET 11 (x64, Linux and Windows).
//
// `IsZero` walks the three components of a vector. Its Tier1 code unrolls that loop, but
// each unrolled copy re-dispatches the switch in `Get` with the index folded to 0, so all
// three copies read component 0. `IsZero` then answers "true" for a vector that is not
// zero. No configuration is needed: this happens on a default installation.

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

internal static class Program
{
    private const int Count = 256;

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

    // Not inlined, so that the hot loop below does not collapse into a single on-stack
    // replacement of Main with everything inlined into it. In that shape `IsZero` never
    // gets compiled on its own and the bug does not appear.
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

    private static int Main()
    {
        var values = new V3[Count];

        for (var i = 0; i < values.Length; i++)
        {
            // Most of them stop IsZero on component 0; the last one only on component 2.
            // The mixture matters: filling the array with one value makes this go away.
            values[i] = i == values.Length - 1 ? new V3(0, 0, 1) : new V3(1, 0, 0);
        }

        for (var round = 0; round < 200000; round++)
        {
            if (CountZero(values) != 0)
            {
                Console.WriteLine($"WRONG round={round}: IsZero(0, 0, 1) returned true");

                return 1;
            }
        }

        return 0;
    }
}
