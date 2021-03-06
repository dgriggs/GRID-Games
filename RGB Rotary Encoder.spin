CON
  _xinfreq=6_250_000            
  _clkmode=xtal1+pll16x

'To balance lighting adjust resistor values on R,B,G. For Sparkfun Illuminated Rotary Encoder (COM-10982) use ~470ohm for R,G, and ~60ohm for B
  Button=4
  Encoder=6
  LED1=8
  LED2=9
  LED3=10

  Data = 15
  CLK  = 14
  Check = 3

  numLEDs = 144
  
OBJ
  pst  : "Parallax Serial Terminal"
  PWM  : "PWM_32_v4.spin"  
                                             
VAR
  long R, G, B, W, knobR, knobG, knobB, Brightness, knobBright
  long Stack[100], Stack2[100], Stack3[100], Stack4[100], Stack5[100], Stack6[100]  
  long pixels[numLEDs] 
  
PUB Main | i
  pst.start(115200)
  dira[LED1..LED3]~~
  dira[Encoder..Encoder+1]~
  dira[Button]~
  
  cognew(PWMs(@knobR,@knobG,@knobB),@Stack)                                                            
  cognew(@Setup,@pixels[0])
  cognew(ColorTest,@Stack5)    
  cognew(ColorControl,@Stack4)
  'CalibrationShow

  repeat
    pst.Str(string("pos - "))
    pst.dec(R)
    pst.Str(string("   color - "))
    pst.Dec(G)             
    pst.Str(string("   knob - "))
    pst.Dec(posR)             
    pst.Str(string("   Duty - "))
    pst.Dec(posG)              
    pst.Str(string("   posW - "))
    pst.Dec(posW)
    pst.NewLine   
    waitcnt(clkfreq/10+cnt)

PUB PWMs(ptr1,ptr2,ptr3)| Duty1,Duty2,Duty3 
  PWM.Start
repeat
  Duty1:=byte[ptr1]*100/255 #>0 <#100
  Duty2:=byte[ptr2]*100/255 #>0 <#100
  Duty3:=byte[ptr3]*100/255 #>0 <#100 
  PWM.Duty(LED1,Duty1,100)
  PWM.Duty(LED2,Duty2,100)
  PWM.Duty(LED3,Duty3,100)
  waitcnt(clkfreq/1000+cnt)
  
PUB ColorTest | i
  repeat
    repeat i from 0 to numLEDs-1
      Set_RGB(i,R,G,B)
      'waitcnt(clkfreq/300+cnt)                            

PUB Set_RGB(led,red,green,blue)
  pixels[led-1]:=%111_11111<<24+gammaLED[blue]<<16+gammaLED[green]<<8+gammaLED[red]
          
PUB ColorControl | flag
  Pin:=5
  TotEnc:=1
  posR:=posG:=posB:=0
  posW:=1020
  repeat  
    knobR:=knobG:=knobB:=255
    waitcnt(clkfreq/8+cnt)
    knobR:=0
    waitcnt(clkfreq/8+cnt)
    knobR:=255

    repeat until ina[Button] == 0
    coginit(7,@Update,@posR)
    repeat until ina[Button] == 1                        'ButtonMode = Choose Red brightness
      
      R:=((posR/4)*posW/1020)
      knobR:=gammaPWM[R]             'Adjust to make sure user knows which color he's controlling, KEEP BELOW value of gamma[255] so you don't go negative
      knobG:=knobB:=255
                          
      if (posR < 1017 AND posR > 3)                            
        flag:=1
      if (posR => 1020 OR posR =< 0) AND flag == 1        'This function warns user when he hits ends of the desired range (0 to 255)
        repeat 2
          knobR:=knobG:=knobB:=255
          waitcnt(clkfreq/8+cnt)
          knobR:=0
          waitcnt(clkfreq/8+cnt)  
        flag:=0
    
    knobR:=knobG:=knobB:=255
    waitcnt(clkfreq/8+cnt)
    knobG:=0
    waitcnt(clkfreq/8+cnt)
    knobG:=255
    
    repeat until ina[Button] == 0 
    coginit(7,@Update,@posG)
    repeat until ina[Button] == 1                        'ButtonMode = Choose Green brightness

      G:=((posG/4)*posW/1020)
      knobG:=gammaPWM[G]             'Adjust to make sure user knows which color he's controlling, KEEP BELOW value of gamma[255] 
      knobR:=knobB:=255

      if (posG < 1017 AND posG > 3)                            
        flag:=1
      if (posG => 1020 OR posG =< 0) AND flag == 1
        repeat 2
          knobR:=knobG:=knobB:=255
          waitcnt(clkfreq/8+cnt)
          knobG:=0
          waitcnt(clkfreq/8+cnt)
        flag:=0

    knobR:=knobG:=knobB:=255
    waitcnt(clkfreq/8+cnt)
    knobB:=0
    waitcnt(clkfreq/8+cnt)
    knobB:=255

    repeat until ina[Button] == 0     
    coginit(7,@Update,@posB)
    repeat until ina[Button] == 1                        'ButtonMode = Choose Blue brightness
                     
      B:=((posB/4)*posW/1020)
      knobB:=gammaPWM[B]             'Adjust to make sure user knows which color he's controlling, KEEP BELOW value of gamma[255]
      knobR:=knobG:=255

      if (posB < 1017 AND posB > 3)                            
        flag:=1
      if (posB => 1020 OR posB =< 0) AND flag == 1
        repeat 2
          knobR:=knobG:=knobB:=255
          waitcnt(clkfreq/8+cnt)
          knobB:=0
          waitcnt(clkfreq/8+cnt)
        flag:=0
 
    knobR:=knobG:=knobB:=255
    waitcnt(clkfreq/8+cnt)
    knobR:=knobG:=knobB:=0
    waitcnt(clkfreq/8+cnt)
    knobR:=knobG:=knobB:=255
          
    repeat until ina[Button] == 0        'Adjust to make sure user knows which color he's controlling, KEEP BELOW value of gamma[255]
    coginit(7,@Update,@posW) 
    repeat until ina[Button] == 1                        'ButtonMode = Choose Total brightness                     
      
      R:=((posR/4)*posW/1020)
      G:=((posG/4)*posW/1020)
      B:=((posB/4)*posW/1020)
      
      knobR:=gammaPWM[R]   
      knobG:=gammaPWM[G]
      knobB:=gammaPWM[B]
      
      if (posW < 1017 AND posW > 3)                            
        flag:=1
      if (posW => 1020 OR posW =< 0) AND flag == 1
        repeat 2
          knobR:=knobG:=knobB:=255
          waitcnt(clkfreq/8+cnt)
          knobR:=knobG:=knobB:=0
          waitcnt(clkfreq/8+cnt)
        flag:=0
                                       
PUB AnPWM(PWMpin,duty) | period   'This method creates a 10kHz PWM signal (duty cycle is set by the
                                'variable at specified central RAM address) clock must be 100MHz
  dira[PWMpin]~~                   'Set the direction of "pin" to be an output for this cog
  ctra[5..0]:=PWMpin               'Set the "A pin" of this cog's "A Counter" to be "pin"
  ctra[30..26]:=%00100          'Set this cog's "A Counter" to run in single-ended NCO/PWM mode
                                ' (where frqa always acccumulates to phsa and the 
                                '  Apin output state is bit 31 of the phsa value)                                            
  frqa:=1                       'Set counter's frqa value to 1 (1 is added to phsa at each clock)
  long[duty]:=0              'Set the value at the specified address to be 0 (0% duty cycle)                                   
  repeat
    repeat while long[duty]==0 'Wait for duty cycle to be set to a non-zero value (by Cog 0)
    period:=10000+cnt             'Calculate the system counter's value after 100 microseconds 
    phsa:=-(long[duty])    'Send a high pulse for specified number of microseconds
    waitcnt(period-1425)          'Wait until 100us have elapsed (subtract 14.25us fudge factor)

PUB CalibrationShow 'Compare R,G,B brightness and adjust resistors to make even brightness across spectrum.
  repeat 
    knobR:=000
    knobG:=10000
    knobB:=10000
    waitcnt(clkfreq/2+cnt)
    knobR:=10000
    knobG:=0000
    knobB:=10000
    waitcnt(clkfreq/2+cnt)
    knobR:=10000
    knobG:=10000
    knobB:=0000
    waitcnt(clkfreq/2+cnt)
    knobR:=10000
    knobG:=10000
    knobB:=10000
    waitcnt(clkfreq+cnt)
    
DAT
Setup                   org     0
                        mov     dira,ClkMask
                        or      dira,DataMask   

'                        or      dira,CheckMask    'Non-vital, use only to see signal on Oscilloscope!

StripLoop               mov     address,par    

'                        mov     outa,CheckMask    'Non-vital, use only to see signal on Oscilloscope!

                        mov     Zeros,#32  

ZerosLoop               or      outa,ClkMask     
                        mov     outa,#0                
                        djnz    Zeros,#ZerosLoop   

                        mov     LEDs,#numLEDs

LEDsLoop                mov     Bits,#32
                        rdlong  temp1,address

BitLoop                 rol     temp1,#1
                        mov     temp2,temp1
                        and     temp2,#1 
                        shl     temp2,#Data
                        mov     outa,temp2
                        or      outa,ClkMask
                        mov     outa,#0                        

BitLoopEnd              djnz    Bits,#BitLoop
                                               
                        add     address,#4                        

LEDsLoopEnd             djnz    LEDs,#LEDsLoop
                        jmp     #StripLoop

ClkMask                 long    %1<<CLK
DataMask                long    %1<<Data    
'CheckMask               long    %1<<Check         'Non-vital, use only to see signal on Oscilloscope!
                                                
address                 res
Zeros                   res   
LEDs                    res  
Bits                    res 
temp1                   res
temp2                   res
                        FIT     496


DAT
{{
*************************************
* Quadrature Encoder v1.0           *
* Author: Jeff Martin               *
* Copyright (c) 2005 Parallax, Inc. *
* See end of file for terms of use. *
*************************************
}}
'Read all encoders and update encoder positions in main memory.
'See "Theory of Operation," below, for operational explanation.
'Cycle Calculation Equation:
'  Terms:     SU = :Sample to :Update.  UTI = :UpdatePos through :IPos.  MMW = Main Memory Write.
'             AMMN = After MMW to :Next.  NU = :Next to :UpdatePos.  SH = Resync to Hub.  NS = :Next to :Sample.
'  Equation:  SU + UTI + MMW + (AMMN + NU + UTI + SH + MMW) * (TotEnc-1) + AMMN + NS
'             = 92 + 16  +  8  + ( 16  + 4  + 16  + 6  +  8 ) * (TotEnc-1) +  16  + 12
'             = 144 + 50*(TotEnc-1)

                        org     0
                                                                                                
Update                  test    Pin, #$20               wc      'Test for upper or lower port
                        muxc    :PinSrc, #%1                    'Adjust :PinSrc instruction for proper port
                        mov     IPosAddr, #IntPos               'Clear all internal encoder position values
                        movd    :IClear, IPosAddr               '  set starting internal pointer
                        mov     Idx, TotEnc                     '  for all encoders...  
        :IClear         rdlong  0, PAR                         '  clear internal memory
                        add     IPosAddr, #1                    '  increment pointer
                        movd    :IClear, IPosAddr               
                        djnz    Idx, #:IClear                   '  loop for each encoder
                                                                
                        mov     St2, ina                        'Take first sample of encoder pins
                        shr     St2, Pin                
:Sample                 mov     IPosAddr, #IntPos               'Reset encoder position buffer addresses
                        movd    :IPos+0, IPosAddr                               
                        movd    :IPos+1, IPosAddr 
                        movd    :IPos+2, IPosAddr   
                        movd    :IPos+3, IPosAddr
                        mov     MPosAddr, PAR                           
                        mov     St1, St2                        'Calc 2-bit signed offsets (St1 = B1:A1)
                        mov     T1,  St2                        '                           T1  = B1:A1 
                        shl     T1, #1                          '                           T1  = A1:x 
        :PinSrc         mov     St2, ina                        '  Sample encoders         (St2 = B2:A2 left shifted by first encoder offset)
                        shr     St2, Pin                        '  Adj for first encoder   (St2 = B2:A2)
                        xor     St1, St2                        '          St1  =              B1^B2:A1^A2
                        xor     T1, St2                         '          T1   =              A1^B2:x
                        and     T1, BMask                       '          T1   =              A1^B2:0
                        or      T1, AMask                       '          T1   =              A1^B2:1
                        mov     T2, St1                         '          T2   =              B1^B2:A1^A2
                        and     T2, AMask                       '          T2   =                  0:A1^A2
                        and     St1, BMask                      '          St1  =              B1^B2:0
                        shr     St1, #1                         '          St1  =                  0:B1^B2
                        xor     T2, St1                         '          T2   =                  0:A1^A2^B1^B2
                        mov     St1, T2                         '          St1  =                  0:A1^B2^B1^A2
                        shl     St1, #1                         '          St1  =        A1^B2^B1^A2:0
                        or      St1, T2                         '          St1  =        A1^B2^B1^A2:A1^B2^B1^A2
                        and     St1, T1                         '          St1  =  A1^B2^B1^A2&A1^B2:A1^B2^B1^A2
                        mov     Idx, TotEnc                     'For all encoders...
:UpdatePos              ror     St1, #2                         'Rotate current bit pair into 31:30
                        mov     Diff, St1                       'Convert 2-bit signed to 32-bit signed Diff
                        sar     Diff, #30 
          :IPos         sub     0, Diff
                        mins    0, #0    
                        maxs    0, MaxPos                        
                        wrlong  0, MPosAddr                     'Write new position to main memory
                        add     IPosAddr, #1                    'Increment encoder position addresses  
                        movd    :IPos+0, IPosAddr
                        movd    :IPos+1, IPosAddr  
                        movd    :IPos+2, IPosAddr  
                        movd    :IPos+3, IPosAddr
                        add     MPosAddr, #4                            
:Next                   djnz    Idx, #:UpdatePos                'Loop for each encoder
                        jmp     #:Sample                        'Loop forever

'Define Encoder Reading Cog's constants/variables

AMask                   long    $55555555                       'A bit mask
BMask                   long    $AAAAAAAA                       'B bit mask
MSB                     long    $80000000                       'MSB mask for current bit pair
FinalMask               long    %1<<10

Pin                     long    0                               'First pin connected to first encoder
TotEnc                  long    0                               'Total number of encoders 
MaxPos                  long    1020
posR                    long    0
posG                    long    0
posB                    long    0
posW                    long    0
                                       
Idx                     res     1                               'Encoder index
St1                     res     1                               'Previous state
St2                     res     1                               'Current state
T1                      res     1                               'Temp 1
T2                      res     1                               'Temp 2
Diff                    res     1                               'Difference, ie: -1, 0 or +1
IPosAddr                res     1                               'Address of current encoder position counter (Internal Memory)
MPosAddr                res     1                               'Address of current encoder position counter (Main Memory)
IntPos                  res     16                              'Internal encoder position counter buffer



{{
**************************
* FUNCTIONAL DESCRIPTION *
**************************

Reads 1 to 16 two-bit gray-code quadrature encoders and provides 32-bit absolute position values for each and optionally provides delta position support
(value since last read) for up to 16 encoders.  See "Required Cycles and Maximum RPM" below for speed boundary calculations.

Connect each encoder to two contiguous I/O pins (multiple encoders must be connected to a contiguous block of pins).  If delta position support is
required, those encoders must be at the start of the group, followed by any encoders not requiring delta position support.

To use this object: 
  1) Create a position buffer (array of longs).  The position buffer MUST contain NumEnc + NumDelta longs.  The first NumEnc longs of the position buffer
     will always contain read-only, absolute positions for the respective encoders.  The remaining NumDelta longs of the position buffer will be "last
     absolute read" storage for providing delta position support (if used) and should be ignored (use ReadDelta() method instead).
  2) Call Start() passing in the starting pin number, number of encoders, number needing delta support and the address of the position buffer.  Start() will
     configure and start an encoder reader in a separate cog; which runs continuously until Stop is called.
  3) Read position buffer (first NumEnc values) to obtain an absolute 32-bit position value for each encoder.  Each long (32-bit position counter) within
     the position buffer is updated automatically by the encoder reader cog.
  4) For any encoders requiring delta position support, call ReadDelta(); you must have first sized the position buffer and configured Start() appropriately
     for this feature.

Example Code:
           
OBJ
  Encoder : "Quadrature Encoder"

VAR
  long Pos[3]                            'Create buffer for two encoders (plus room for delta position support of 1st encoder)

PUB Init
  Encoder.Start(8, 2, 1, @Pos)           'Start continuous two-encoder reader (encoders connected to pins 8 - 11)

PUB Main 
  repeat
    <read Pos[0] or Pos[1] here>         'Read each encoder's absolute position
    <variable> := Encoder.ReadDelta(0)   'Read 1st encoder's delta position (value since last read)

________________________________
REQUIRED CYCLES AND MAXIMUM RPM:

Encoder Reading Cog requires 144 + 50*(TotEnc-1) cycles per sample.  That is: 144 for 1 encoder, 194 for 2 encoders, 894 for 16 encoders.

Conservative Maximum RPM of Highest Resolution Encoder = XINFreq * PLLMultiplier / EncReaderCogCycles / 2 / MaxEncPulsesPerRevolution * 60

Example 1: Using a 4 MHz crystal, 8x internal multiplier, 16 encoders where the highest resolution encoders is 1024 pulses per revolution:
           Max RPM = 4,000,000 * 8 / 894 / 2 / 1024 * 60 = 1,048 RPM

Example 2: Using same example above, but with only 2 encoders of 128 pulses per revolution:
           Max RPM = 4,000,000 * 8 / 194 / 2 / 128 * 60 = 38,659 RPM
}}


{
____________________
THEORY OF OPERATION:
Column 1 of the following truth table illustrates 2-bit, gray code quadrature encoder output (encoder pins A and B) and their possible transitions (assuming
we're sampling fast enough).  A1 is the previous value of pin A, A2 is the current value of pin A, etc.  '->' means 'transition to'.  The four double-step
transition possibilities are not shown here because we won't ever see them if we're sampling fast enough and, secondly, it is impossible to tell direction
if a transition is missed anyway.

Column 2 shows each of the 2-bit results of cross XOR'ing the bits in the previous and current values.  Because of the encoder's gray code output, when
there is an actual transition, A1^B2 (msb of column 2) yields the direction (0 = clockwise, 1 = counter-clockwise).  When A1^B2 is paired with B1^A2, the
resulting 2-bit value gives more transition detail (00 or 11 if no transition, 01 if clockwise, 10 if counter-clockwise).

Columns 3 and 4 show the results of further XORs and one AND operation.  The result is a convenient set of 2-bit signed values: 0 if no transition, +1 if
clockwise, and -1 and if counter-clockwise.

This object's Update routine performs the sampling (column 1) and logical operations (colum 3) of up to 16 2-bit pairs in one operation, then adds the 
resulting offset (-1, 0 or +1) to each position counter, iteratively.

      1      |      2      |          3           |       4        |     5
-------------|-------------|----------------------|----------------|-----------
             |             | A1^B2^B1^A2&(A1^B2): |   2-bit sign   |
B1A1 -> B2A2 | A1^B2:B1^A2 |     A1^B2^B1^A2      | extended value | Diagnosis
-------------|-------------|----------------------|----------------|-----------
 00  ->  00  |     00      |          00          |      +0        |    No
 01  ->  01  |     11      |          00          |      +0        | Movement
 11  ->  11  |     00      |          00          |      +0        |
 10  ->  10  |     11      |          00          |      +0        |
-------------|-------------|----------------------|----------------|-----------
 00  ->  01  |     01      |          01          |      +1        | Clockwise
 01  ->  11  |     01      |          01          |      +1        |
 11  ->  10  |     01      |          01          |      +1        |
 10  ->  00  |     01      |          01          |      +1        |
-------------|-------------|----------------------|----------------|-----------
 00  ->  10  |     10      |          11          |      -1        | Counter-
 10  ->  11  |     10      |          11          |      -1        | Clockwise
 11  ->  01  |     10      |          11          |      -1        |
 01  ->  00  |     10      |          11          |      -1        |
}

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}

DAT 'Gamma correction        
gammaLED      byte 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3
              byte 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8
              byte 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 16, 16, 17, 17, 18
              byte 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 23, 24, 24, 25, 25, 26, 26, 27, 27, 28, 28
              byte 29, 30, 30, 31, 31, 32, 32, 33, 33, 34, 34, 35, 35, 36, 36, 37, 37, 38, 38, 39, 40
              byte 41, 42, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 52, 53, 54, 55, 56, 57, 59, 60
              byte 61, 62, 63, 64, 65, 66, 67, 68, 69, 71, 72, 73, 74, 75, 77, 78, 79, 80, 82, 83, 84
              byte 85, 87, 88, 89, 91, 92, 93, 95, 96, 98, 99, 100, 102, 103, 105, 106, 108, 109, 111
              byte 112, 114, 115, 117, 119, 120, 122, 123, 125, 127, 128, 130, 132, 133, 135, 137, 138
              byte 140, 142, 144, 145, 147, 149, 151, 153, 155, 156, 158, 160, 162, 164, 166, 168, 170
              byte 172, 174, 176, 178, 180, 182, 184, 186, 188, 190, 192, 194, 197, 199, 201, 203, 205
              byte 207, 210, 212, 214, 216, 219, 221, 223, 226, 228, 230, 233, 235, 237, 240, 242, 245
              byte 247, 250, 252, 255

DAT 'Gamma correction        
gammaPWM      byte 255, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 253
              byte 253, 253, 253, 253, 253, 253, 253, 253, 253, 253, 252, 252, 252, 252, 252, 252
              byte 251, 251, 251, 251, 251, 251, 250, 250, 250, 250, 250, 250, 249, 249, 249, 249
              byte 249, 248, 248, 248, 248, 247, 247, 247, 247, 246, 246, 246, 245, 245, 245, 244
              byte 244, 244, 243, 243, 243, 242, 242, 242, 241, 241, 241, 240, 240, 239, 239, 238
              byte 238, 237, 237, 236, 236, 235, 235, 234, 234, 233, 233, 232, 232, 231, 231, 230
              byte 230, 229, 229, 228, 228, 227, 227, 226, 225, 225, 224, 224, 223, 223, 222, 222
              byte 221, 221, 220, 220, 219, 219, 218, 218, 217, 217, 216, 215, 214, 213, 213, 212
              byte 211, 210, 209, 208, 207, 206, 205, 204, 203, 203, 202, 201, 200, 199, 198, 196
              byte 195, 194, 193, 192, 191, 190, 189, 188, 187, 186, 184, 183, 182, 181, 180, 178
              byte 177, 176, 175, 173, 172, 171, 170, 168, 167, 166, 164, 163, 162, 160, 159, 157
              byte 156, 155, 153, 152, 150, 149, 147, 146, 144, 143, 141, 140, 138, 136, 135, 133
              byte 132, 130, 128, 127, 125, 123, 122, 120, 118, 117, 115, 113, 111, 110, 108, 106
              byte 104, 102, 100, 99, 97, 95, 93, 91, 89, 87, 85, 83, 81, 79, 77, 75
              byte 73, 71, 69, 67, 65, 63, 61, 58, 56, 54, 52, 50, 48, 45, 43, 41
              byte 39, 36, 34, 32, 29, 27, 25, 22, 20, 18, 15, 13, 10, 8, 5, 3, 0
              