# Pulse Oximeter Bluetooth protocol analysis

I ordered several devices. I have three on hand right now, and I was
surprised to find that the protocol is different for each of them.

## Wellue/Viatom KS-60FW

GATT Scan:

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
