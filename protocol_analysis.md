# Pulse Oximeter Bluetooth protocol analysis

I ordered several devices. I have three on hand right now, and I was
surprised to find that the protocol is different for each of them.

## Tools used for analysis

* [`blew`](https://github.com/stass/blew) — MacOS BLE utility
* [LightBlue](https://punchthrough.com/resources/lightblue/) — Android BLE utility

## Wellue/Viatom KS-60FW

BLE Advertised Name: `KS-60FW 4482`

GATT Tree:

```
Service 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
├── 6E400002-B5A3-F393-E0A9-E50E24DCCA9E  [write, writeNoResp]
└── 6E400003-B5A3-F393-E0A9-E50E24DCCA9E  [notify]
    └── 2902  Client Characteristic Configuration

Service FE59
├── 8EC90001-F315-4F60-9FB8-838830DAEA50  [write, notify]
│   └── 2902  Client Characteristic Configuration
├── 8EC90002-F315-4F60-9FB8-838830DAEA50  [read, writeNoResp]  =
└── 0003  [read]  = 76657273696f6e2d76300000
```

Subscribing to `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` produces data. The
other notify characteristic produces nothing.

The data is in one of four formats:

1. `aa550f07025a57d24c45a7`
2. `aa550f08015f55005700c0da`
3. `aa550f06210200000045`
4. `aa55f0030303f6`

Data type 1 seems to be the primary data transfer and is produced approximately
10 times per second. The other three are produced approximately once per
second. I have not observed data types 3 and 4 ever changing.

Data type 1 seems to have this format:

`aa550f0702VVWWXXYYZZQQ`

`aa550f0702` seems to be an unchanging header. The octets called out as
`V`, `W`, `X`, `Y`, and `Z` appear to contain individual pleth datapoints.
The data appears to be in the seven least significant bits. The most
significant bit is set seemingly once per beat, seemingly shortly after
the peak.

The `Q` octet is variable. I'm guessing it contains at least some of the
other data: Sp0₂, Pulse Rate, and Perfusion Index. Sp0₂ and Pulse Rate
seem to update on-device more than once per second, so I don't think that
they're in data type 2. Perfusion Index may update less frequently, so maybe
it's in data type 2.

## Innovo iP900BP-B

BLE Advertised Name: `iP900BPB`

GATT Tree:

```
Service 180A  Device Information
├── 2A24  Model Number String  [read]  = C228_D4
├── 2A25  Serial Number String  [read]  = 433232385F4434
├── 2A28  Software Revision String  [read]  = 1.0.0
└── 2A29  Manufacturer Name String  [read]  = ChoiceMMed

Service 180F  Battery Service
└── 2A19  Battery Level  [read]  = 82
    ├── 2904  Characteristic Presentation Format
    └── 2902  Client Characteristic Configuration

Service 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
├── FFF0  [indicate]
│   └── 2902  Client Characteristic Configuration
├── FFF1  [notify]
│   └── 2902  Client Characteristic Configuration
└── FFF2  [read]  = 43002000240800

Service 00000001-0000-6465-6D6D-65636C6F6843
├── 00000002-0000-6465-6D6D-65636C6F6843  [read]  = f650d8212b00
│   └── 2902  Client Characteristic Configuration
├── 00000003-0000-6465-6D6D-65636C6F6843  [notify]
│   └── 2902  Client Characteristic Configuration
├── 00000004-0000-6465-6D6D-65636C6F6843  [write]
└── 00000005-0000-6465-6D6D-65636C6F6843  [read]  = 00
```

In order to produce data, both `FFF0` and `FFF1` must be subscribed to,
after which data will be produced on `FFF1`.

The data is in one of two formats:

1. `01xx`
2. `3Ess00pp00rr2000000000iiF0`

Data type 1 is produced approximately 24 times per second and the `xx`
octet is the pleth datapoint. Data type 2 is produced once per second
and contains SpO₂(`ss`), pulse rate(`pp`), respiration rate(`rr`), and
perfusion index(`ii`). (Perfusion index is reported in tenths of
percentages [permillages?].) `3E` and the two `00`s are unchanging. The
`2000000000` and `F0` change occasionally, and seem to indicate status
and/or errors, such as "Finger Removed". It's possible some of the `00`s
are intended to be part of the data.

## Zacurate 500E-B

BLE Advertised Name: `500E-B`

GATT Tree:

```
Service 180A  Device Information
├── 2A24  Model Number String  [read]  = C228_D4
├── 2A25  Serial Number String  [read]  = 433232385F4434
├── 2A28  Software Revision String  [read]  = 1.0.0
└── 2A29  Manufacturer Name String  [read]  = ChoiceMMed

Service 180F  Battery Service
└── 2A19  Battery Level  [read]  = 100
    ├── 2904  Characteristic Presentation Format
    └── 2902  Client Characteristic Configuration

Service 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
├── FFF0  [indicate]
│   └── 2902  Client Characteristic Configuration
├── FFF1  [notify]
│   └── 2902  Client Characteristic Configuration
└── FFF2  [read]  = 43002000240800

Service 00000001-0000-6465-6D6D-65636C6F6843
├── 00000002-0000-6465-6D6D-65636C6F6843  [read]  = ed9b676d0f68
│   └── 2902  Client Characteristic Configuration
├── 00000003-0000-6465-6D6D-65636C6F6843  [notify]
│   └── 2902  Client Characteristic Configuration
├── 00000004-0000-6465-6D6D-65636C6F6843  [write]
└── 00000005-0000-6465-6D6D-65636C6F6843  [read]  = 00

Service FF00
├── FF01  [read, write, writeNoResp, notify]  = 000000000000000000000000000000000000000000
│   └── 2902  Client Characteristic Configuration
├── FF02  [read, write, writeNoResp]  = 000000000000000000000000000000000000000000
└── FF03  [read, write, writeNoResp]  = 00
```

This functions identically to the "Innovo iP900BP-B", down to the "random"
service UUIDs being the same.

## iHealth PO3

BLE Advertised Name: `Pulse Oximeter`

GATT Tree:

```
Service 180A  Device Information
├── 2A23  System ID  [read]  = 0000000000000000
├── 2A24  Model Number String  [read]  = PO3 11070
├── 2A25  Serial Number String  [read]  = e04e7a8e675d
├── 2A26  Firmware Revision String  [read]  = 324
├── 2A27  Hardware Revision String  [read]  = 800
├── 2A28  Software Revision String  [read]  = 180
├── 2A29  Manufacturer Name String  [read]  = iHealth
├── 2A2A  IEEE 11073-20601 Regulatory Certification Data List  [read]  = fe006578706572696d656e74616c
├── 2A50  PnP ID  [read]
│     Vendor ID Source: 1
│     Vendor ID: 2007
│     Product ID: 0
│     Product Version: 272
├── 2A30  Position 3D  [read]  = 636f6d2e6a6975616e2e504f56313100
└── 2A31  Scan Refresh  [read]  = 50756c7365204f78696d657465720000

Service 636F6D2E-6A69-7561-6E2E-504F56313100
└── 7274782E-6A69-7561-6E2E-504F56313100  [write, writeNoResp, notify]
    ├── 2902  Client Characteristic Configuration
    └── 2901  Characteristic User Descriptor
```

I have yet to get this to produce any useful data.

Turns out that this is likely encrypted to prevent any access to the
data that's not approved by the manufacturer. ([source](https://stackoverflow.com/a/79836593))
Notably, it doesn't seem to be anything that prevents unauthorized access
to the device. Someone could still sidle up next to a person using one of
these and get data from it without their knowledge. [The manufacturer
has an SDK](https://dev.ihealthlabs.com/) that requires signing up
for a developer account. This all feels like claiming your personal
medical information as their own. I am not interested in supporting this,
and nor should you be. You should boycott this device and also the
manufacturer in general.
