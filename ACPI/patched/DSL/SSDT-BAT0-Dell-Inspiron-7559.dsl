//
// In config ACPI, _BIF to XBIF
// Find:     5F424946
// Replace:  58424946
//
// In config ACPI, _BST to XBST
// Find:     5F425354
// Replace:  58425354
//
DefinitionBlock ("", "SSDT", 2, "OCLT", "BAT0", 0)
{
    External (_SB.PCI0, DeviceObj)
    External (_SB.PCI0.LPCB, DeviceObj)
    External (_SB.PCI0.LPCB.BAT0, DeviceObj)
    External (_SB.PCI0.LPCB.BAT0.BFB0, PkgObj)
    External (_SB.PCI0.LPCB.BAT0.ITOS, MethodObj)
    External (_SB.PCI0.LPCB.BAT0.XBST, MethodObj)
    External (_SB.PCI0.LPCB.BAT0.XBIF, MethodObj)
    External (_SB.PCI0.LPCB.BAT0.PAK0, PkgObj)
    External (_SB.PCI0.LPCB.EC, DeviceObj)
    External (_SB.PCI0.LPCB.EC.B0CL, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC.B0DC, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC.B0IC, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC.BCN0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC.DNN0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC.MNN0, FieldUnitObj)
    External (_SB.PCI0.LPCB.EC.MUTX, MutexObj)
    External (_SB.PCI0.LPCB.ECOK, MethodObj)
    External (_SB.PWRS, FieldUnitObj)
    External (BFB0, IntObj)
    External (PAK0, IntObj)
    External (PWRS, IntObj)

    Method (B1B2, 2, NotSerialized)
    {
        Return ((Arg0 | (Arg1 << 0x08)))
    }

    Scope (_SB.PCI0.LPCB.EC)
    {
        OperationRegion (ERM2, EmbeddedControl, Zero, 0x0100)
        Field (ERM2, ByteAcc, Lock, Preserve)
        {
            Offset (0xA0), 
            DAP0,   8, 
            DAP1,   8, 
            Offset (0xA4), 
            WOT0,   8, 
            WOT1,   8, 
            DRT0,   8, 
            DRT1,   8, 
            Offset (0xAA), 
            Offset (0xAC), 
            Offset (0xAE), 
            GCP0,   8, 
            GCP1,   8, 
            ECP0,   8, 
            ECP1,   8, 
            EVT0,   8, 
            EVT1,   8, 
            Offset (0xB6), 
            Offset (0xB8), 
            CSN0,   8, 
            CSN1,   8, 
            Offset (0xBC)
        }
    }

    Scope (_SB.PCI0.LPCB.BAT0)
    {
        Method (_BST, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
            If (ECOK ())
            {
                Acquire (^^EC.MUTX, 0xFFFF)
                Local0 = ^^EC.B0DC
                Local1 = ^^EC.B0IC
                Local1 <<= One
                Local0 += Local1
                Local1 = ^^EC.B0CL
                Release (^^EC.MUTX)
                Local1 <<= 0x02
                Local0 += Local1
                BFB0 [Zero] = Local0
                Acquire (^^EC.MUTX, 0xFFFF)
                BFB0 [0x02] = B1B2 (^^EC.DAP0, ^^EC.DAP1)
                BFB0 [0x03] = B1B2 (^^EC.WOT0, ^^EC.WOT1)
                Release (^^EC.MUTX)
                Acquire (^^EC.MUTX, 0xFFFF)
                Local0 = B1B2 (^^EC.DRT0, ^^EC.DRT1)
                Release (^^EC.MUTX)
                If ((Local0 == Zero))
                {
                    Local0++
                }
                ElseIf (PWRS)
                {
                    If ((Local0 & 0x8000))
                    {
                        Local0 = Ones
                    }
                }
                ElseIf ((Local0 & 0x8000))
                {
                    Local0 = (Zero - Local0)
                    Local0 &= 0xFFFF
                }
                Else
                {
                    Local0 = Ones
                }

                BFB0 [One] = Local0
            }

            Return (BFB0)
            }
            Else
            {
                Return (\_SB.PCI0.LPCB.BAT0.XBST ())
            }
        }

        Method (_BIF, 0, Serialized)
        {
            If (_OSI ("Darwin"))
            {
            If (ECOK ())
            {
                Acquire (^^EC.MUTX, 0xFFFF)
                PAK0 [One] = B1B2 (^^EC.ECP0, ^^EC.ECP1)
                Local0 = B1B2 (^^EC.GCP0, ^^EC.GCP1)
                PAK0 [0x02] = Local0
                PAK0 [0x04] = B1B2 (^^EC.EVT0, ^^EC.EVT1)
                Local1 = ^^EC.DNN0
                Local2 = B1B2 (^^EC.CSN0, ^^EC.CSN1)
                Local3 = ^^EC.BCN0
                Local4 = ^^EC.MNN0
                Release (^^EC.MUTX)
                PAK0 [0x05] = (Local0 / 0x0A)
                PAK0 [0x06] = Zero
                Switch (ToInteger (Local1))
                {
                    Case (Zero)
                    {
                        PAK0 [0x09] = "Unknow"
                    }
                    Case (0xFF)
                    {
                        PAK0 [0x09] = "Dell"
                    }

                }

                PAK0 [0x0A] = ITOS (ToBCD (Local2))
                Switch (ToInteger (Local3))
                {
                    Case (Zero)
                    {
                        PAK0 [0x0B] = "Unknow"
                    }
                    Case (One)
                    {
                        PAK0 [0x0B] = "PBAC"
                    }
                    Case (0x02)
                    {
                        PAK0 [0x0B] = "LION"
                    }
                    Case (0x03)
                    {
                        PAK0 [0x0B] = "NICD"
                    }
                    Case (0x04)
                    {
                        PAK0 [0x0B] = "NIMH"
                    }
                    Case (0x05)
                    {
                        PAK0 [0x0B] = "NIZN"
                    }
                    Case (0x06)
                    {
                        PAK0 [0x0B] = "RAM"
                    }
                    Case (0x07)
                    {
                        PAK0 [0x0B] = "ZNAR"
                    }
                    Case (0x08)
                    {
                        PAK0 [0x0B] = "LIP"
                    }

                }

                Switch (ToInteger (Local4))
                {
                    Case (Zero)
                    {
                        PAK0 [0x0C] = "Unknown"
                    }
                    Case (One)
                    {
                        PAK0 [0x0C] = "Dell"
                    }
                    Case (0x02)
                    {
                        PAK0 [0x0C] = "SONY"
                    }
                    Case (0x03)
                    {
                        PAK0 [0x0C] = "SANYO"
                    }
                    Case (0x04)
                    {
                        PAK0 [0x0C] = "PANASONIC"
                    }
                    Case (0x05)
                    {
                        PAK0 [0x0C] = "SONY_OLD"
                    }
                    Case (0x06)
                    {
                        PAK0 [0x0C] = "SDI"
                    }
                    Case (0x07)
                    {
                        PAK0 [0x0C] = "SIMPLO"
                    }
                    Case (0x08)
                    {
                        PAK0 [0x0C] = "MOTOROLA"
                    }
                    Case (0x09)
                    {
                        PAK0 [0x0C] = "LGC"
                    }

                }
            }

            Return (PAK0)
            }
            Else
            {
                Return (\_SB.PCI0.LPCB.BAT0.XBIF ())
            }
        }
    }
}

