say "hi"

edd = .encdec~new
edd~pp("Encode / Decode Data:")

call thdrs
th = result
th~pp("Test Header List:")
thcl = th~clone
thcl~pp("Cloned Test Header List:")

thcl~encode(edd)
thcl~pp("Encoded Test Header List:")
thcldec = thcl~clone
thcldec~decode(edd)
thcldec~pp("Re-dncoded Test Header List:")

say;say "bye"
exit

--
::routine thdrs
    th = .headers~new
    ha = .header~new("K\A", "V\A")
    hb = .header~new("K:B", "V:B")
    hc = .header~new("K" || .string~nl || "C", "V" || .string~nl || "C")
    hd = .header~new("KD", "V" || "0d"~x2c || "D")
    th~add(ha); th~add(hb); th~add(hc); th~add(hd)
    return th

--
::requires "../stomprx.rex"
