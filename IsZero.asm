; Assembly listing for method Program:IsZero(V3):bool (Instrumented Tier0)
; Emitting BLENDED_CODE for generic X64 + VEX on Unix
; Instrumented Tier0 code
; rbp based frame
; partially interruptible
; compiling with minopt

G_M000_IG01:
       push     rbp
       sub      rsp, 80
       lea      rbp, [rsp+0x50]
       xor      eax, eax
       mov      dword ptr [rbp-0x2C], eax
 
G_M000_IG02:
       mov      dword ptr [rbp-0x38], 0x3E8
       xor      eax, eax
       mov      dword ptr [rbp-0x2C], eax
       jmp      SHORT G_M000_IG06
 
G_M000_IG03:
       vmovdqu  xmm0, xmmword ptr [rbp+0x10]
       vmovdqu  xmmword ptr [rsp], xmm0
       mov      rax, qword ptr [rbp+0x20]
       mov      qword ptr [rsp+0x10], rax
       mov      edi, dword ptr [rbp-0x2C]
       call     [V3:Get(V3,int):long]
       test     rax, rax
       je       SHORT G_M000_IG05
       mov      rdi, 0xD1FFAB1E
       call     CORINFO_HELP_COUNTPROFILE32
       xor      eax, eax
 
G_M000_IG04:
       add      rsp, 80
       pop      rbp
       ret      
 
G_M000_IG05:
       mov      rdi, 0xD1FFAB1E
       call     CORINFO_HELP_COUNTPROFILE32
       mov      eax, dword ptr [rbp-0x2C]
       inc      eax
       mov      dword ptr [rbp-0x2C], eax
 
G_M000_IG06:
       mov      eax, dword ptr [rbp-0x38]
       dec      eax
       mov      dword ptr [rbp-0x38], eax
       cmp      dword ptr [rbp-0x38], 0
       jg       SHORT G_M000_IG08
 
G_M000_IG07:
       lea      rdi, [rbp-0x38]
       mov      esi, 19
       call     CORINFO_HELP_PATCHPOINT
 
G_M000_IG08:
       cmp      dword ptr [rbp-0x2C], 3
       jl       SHORT G_M000_IG03
       mov      rdi, 0xD1FFAB1E
       call     CORINFO_HELP_COUNTPROFILE32
       mov      eax, 1
 
G_M000_IG09:
       add      rsp, 80
       pop      rbp
       ret      
 
; Total bytes of code 168

; Assembly listing for method Program:IsZero(V3):bool (Instrumented Tier0)
; Emitting BLENDED_CODE for generic X64 + VEX on Unix
; Instrumented Tier0 code
; rbp based frame
; partially interruptible
; compiling with minopt

G_M000_IG01:
       push     rbp
       sub      rsp, 80
       lea      rbp, [rsp+0x50]
       xor      eax, eax
       mov      dword ptr [rbp-0x2C], eax
 
G_M000_IG02:
       mov      dword ptr [rbp-0x38], 0x3E8
       xor      eax, eax
       mov      dword ptr [rbp-0x2C], eax
       jmp      SHORT G_M000_IG06
 
G_M000_IG03:
       vmovdqu  xmm0, xmmword ptr [rbp+0x10]
       vmovdqu  xmmword ptr [rsp], xmm0
       mov      rax, qword ptr [rbp+0x20]
       mov      qword ptr [rsp+0x10], rax
       mov      edi, dword ptr [rbp-0x2C]
       call     [V3:Get(V3,int):long]
       test     rax, rax
       je       SHORT G_M000_IG05
       mov      rdi, 0xD1FFAB1E
       call     CORINFO_HELP_COUNTPROFILE32
       xor      eax, eax
 
G_M000_IG04:
       add      rsp, 80
       pop      rbp
       ret      
 
G_M000_IG05:
       mov      rdi, 0xD1FFAB1E
       call     CORINFO_HELP_COUNTPROFILE32
       mov      eax, dword ptr [rbp-0x2C]
       inc      eax
       mov      dword ptr [rbp-0x2C], eax
 
G_M000_IG06:
       mov      eax, dword ptr [rbp-0x38]
       dec      eax
       mov      dword ptr [rbp-0x38], eax
       cmp      dword ptr [rbp-0x38], 0
       jg       SHORT G_M000_IG08
 
G_M000_IG07:
       lea      rdi, [rbp-0x38]
       mov      esi, 19
       call     CORINFO_HELP_PATCHPOINT
 
G_M000_IG08:
       cmp      dword ptr [rbp-0x2C], 3
       jl       SHORT G_M000_IG03
       mov      rdi, 0xD1FFAB1E
       call     CORINFO_HELP_COUNTPROFILE32
       mov      eax, 1
 
G_M000_IG09:
       add      rsp, 80
       pop      rbp
       ret      
 
; Total bytes of code 168

; Assembly listing for method Program:IsZero(V3):bool (Tier1)
; Emitting BLENDED_CODE for generic X64 + VEX on Unix
; Tier1 code
; optimized code
; optimized using Synthesized PGO
; rbp based frame
; partially interruptible
; with Synthesized PGO: fgCalledCount is 1925086
; 1 inlinees with PGO data; 0 single block inlinees; 0 inlinees without PGO data

G_M000_IG01:
       push     rbp
       push     rbx
       push     rax
       lea      rbp, [rsp+0x10]
 
G_M000_IG02:
       xor      eax, eax
       jne      SHORT G_M000_IG07
 
G_M000_IG03:
       mov      rdi, qword ptr [rbp+0x10]
 
G_M000_IG04:
       test     rdi, rdi
       je       SHORT G_M000_IG11
 
G_M000_IG05:
       xor      eax, eax
 
G_M000_IG06:
       add      rsp, 8
       pop      rbx
       pop      rbp
       ret      
 
G_M000_IG07:
       xor      eax, eax
       cmp      eax, 2
       ja       G_M000_IG25
 
G_M000_IG08:
       mov      eax, eax
       lea      rdi, [reloc @RWD00]
       mov      edi, dword ptr [rdi+4*rax]
       lea      rcx, G_M000_IG02
       add      rdi, rcx
       jmp      rdi
 
G_M000_IG09:
       mov      rdi, qword ptr [rbp+0x20]
       jmp      SHORT G_M000_IG04
 
G_M000_IG10:
       mov      rdi, qword ptr [rbp+0x18]
       jmp      SHORT G_M000_IG04
 
G_M000_IG11:
       mov      edi, 1
       test     edi, edi
       je       SHORT G_M000_IG15
 
G_M000_IG12:
       xor      eax, eax
       cmp      eax, 2
       ja       SHORT G_M000_IG25
       lea      rdi, [reloc @RWD12]
       mov      edi, dword ptr [rdi+4*rax]
       lea      rcx, G_M000_IG02
       add      rdi, rcx
       jmp      rdi
 
G_M000_IG13:
       mov      rdi, qword ptr [rbp+0x20]
       jmp      SHORT G_M000_IG16
 
G_M000_IG14:
       mov      rdi, qword ptr [rbp+0x18]
       jmp      SHORT G_M000_IG16
 
G_M000_IG15:
       mov      rdi, qword ptr [rbp+0x10]
 
G_M000_IG16:
       test     rdi, rdi
       jne      SHORT G_M000_IG05
 
G_M000_IG17:
       mov      edi, 2
       test     edi, edi
       je       SHORT G_M000_IG22
 
G_M000_IG18:
       xor      eax, eax
       cmp      eax, 2
       ja       SHORT G_M000_IG25
 
G_M000_IG19:
       mov      eax, eax
       lea      rdi, [reloc @RWD24]
       mov      edi, dword ptr [rdi+4*rax]
       lea      rcx, G_M000_IG02
       add      rdi, rcx
       jmp      rdi
 
G_M000_IG20:
       mov      rdi, qword ptr [rbp+0x20]
       jmp      SHORT G_M000_IG23
 
G_M000_IG21:
       mov      rdi, qword ptr [rbp+0x18]
       jmp      SHORT G_M000_IG23
 
G_M000_IG22:
       mov      rdi, qword ptr [rbp+0x10]
 
G_M000_IG23:
       test     rdi, rdi
       sete     al
       movzx    rax, al
 
G_M000_IG24:
       add      rsp, 8
       pop      rbx
       pop      rbp
       ret      
 
G_M000_IG25:
       mov      rdi, 0xD1FFAB1E
       call     CORINFO_HELP_NEWSFAST
       mov      rbx, rax
       mov      edi, 1
       mov      rsi, 0xD1FFAB1E
       call     [CORINFO_HELP_STRCNS]
       mov      rsi, rax
       mov      rdi, rbx
       call     [System.ArgumentOutOfRangeException:.ctor(System.String):this]
       mov      rdi, rbx
       call     CORINFO_HELP_THROW
       int3     
 
RWD00  	dd	G_M000_IG03 - G_M000_IG02
       	dd	G_M000_IG10 - G_M000_IG02
       	dd	G_M000_IG09 - G_M000_IG02
RWD12  	dd	G_M000_IG15 - G_M000_IG02
       	dd	G_M000_IG14 - G_M000_IG02
       	dd	G_M000_IG13 - G_M000_IG02
RWD24  	dd	G_M000_IG22 - G_M000_IG02
       	dd	G_M000_IG21 - G_M000_IG02
       	dd	G_M000_IG20 - G_M000_IG02

; Total bytes of code 268

