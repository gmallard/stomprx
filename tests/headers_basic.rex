/*
 Copyright © 2019 Guy M. Allard

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http:www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

    call hadd
    say
    call hrmkey
    say
    call hvalue
    say
    call hallvalues
    say
    call hmth
    say
    call hclone
    say
    call hcomp
    say
    call hsetval
    say
    call hsetkey
    say
    call hconnhdrs
    exit

--
::routine hadd
    hl = .headers~new
    --
    rv = hl~add("junk")
    say "Retrun from junk add is:" rv
    nh = .header~new("KA", "VA")
    rv = hl~add(nh)
    say "Retrun from OK add is:" rv
    hl~pp("hadd test header list:")

--
::routine hrmkey
    hl = .headers~new
    ha = .header~new("KA", "VA")
    hb = .header~new("KB", "VB")
    hc = .header~new("KC", "VC")
    hl~add(ha); hl~add(hb); hl~add(hc)
    hl~pp("hrmkey start:")
    --
    hl~rmkey("KB")
    hl~pp("hrmkey after rm KB:")

--
::routine hvalue
    hl = .headers~new
    ha = .header~new("KA", "VA")
    hb = .header~new("KB", "VB1")
    hc = .header~new("KC", "VC")
    hb2 = .header~new("KB", "VB2")
    hl~add(ha); hl~add(hb); hl~add(hc); hl~add(hb2)
    hl~pp("hvalue start:")
    --
    vbx = hl~value("KB")
    say "vbx is:" vbx

--
::routine hallvalues
    hl = .headers~new
    ha = .header~new("KA", "VA")
    hb = .header~new("KB", "VB1")
    hc = .header~new("KC", "VC")
    hb2 = .header~new("KB", "VB2")
    hl~add(ha); hl~add(hb); hl~add(hc); hl~add(hb2)
    hl~pp("hallvalues start:")
    --
    vbx = hl~allvalues("KB")
    say "vbx isArray?:" vbx~isA(.array)
    say "vbx is:" vbx
    do nv over vbx~allItems
        say "Next Value:" nv
    end

--
::routine hmth
    hl = .headers~new
    say "MT Headers:" hl~wirestring
    say "MT Headers Hex:" hl~wirestring~c2x

--
::routine hclone
    hl = .headers~new
    ha = .header~new("KA", "VA")
    hb = .header~new("KB", "VB")
    hc = .header~new("KC", "VC")
    hl~add(ha); hl~add(hb); hl~add(hc)
    hl~pp("Clone Header Start:")
    hlcl = hl~clone
    hlcl~pp("Cloned Header Object:")
    --
    say "Compare is:" hl~equals(hlcl)

--
::routine hcomp
    hl = .headers~new
    ha = .header~new("KA", "VA")
    hb = .header~new("KB", "VB")
    hc = .header~new("KC", "VC")
    hl~add(ha); hl~add(hb); hl~add(hc)
    hl2 = .headers~new
    ha = .header~new("KA", "VA")
    hb = .header~new("KB2", "VB")
    hc = .header~new("KC", "VC")
    hl2~add(ha); hl2~add(hb); hl2~add(hc)
    say "Compare (F) is:" hl~equals(hl2)

--
::routine hsetval
    hl = .headers~new
    ha = .header~new("KA", "VA")
    hb = .header~new("KB", "VB")
    hc = .header~new("KC", "VC")
    hl~add(ha); hl~add(hb); hl~add(hc)
    hl~pp("hsetval start:")
    hl~setvalue("KA", "NEWVA")
    hl~pp("hsetval after set:")

--
::routine hsetkey
    hl = .headers~new
    ha = .header~new("KA", "VA")
    hb = .header~new("KB", "VB")
    hc = .header~new("KC", "VC")
    hl~add(ha); hl~add(hb); hl~add(hc)
    hl~pp("hsetkey start:")
    hl~setkey("KA", "NEWKA")
    hl~pp("hsetkey after set:")

--
::routine hconnhdrs
    h10 = .headers~connhdr10
    h10~pp("1.0 connect headers:")
    h11 = .headers~connhdr11
    h11~pp("1.1 connect headers:")
    h12 = .headers~connhdr12
    h12~pp("1.2 connect headers:")

::requires "../lib/header.cls"
::requires "../lib/headers.cls"
