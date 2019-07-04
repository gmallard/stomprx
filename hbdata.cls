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
--
-- Stomp Heart Beat Data
--
::class hbdata public

::attribute runr get
::attribute runw get
::attribute lr
::attribute lw
::attribute rms get
::attribute wms get
::attribute rsecs get
::attribute wsecs get
::attribute wc

::method init public
    expose runr runw lr lw rms wms rsecs wsecs wc
    use strict arg cld, srd
    -- Defaults
    runr = .false
    runw = .false
    lr = 0
    lw = 0
    rms = 0
    wms = 0
    rsecs = 0
    wsecs = 0
    wc = 0
    --
    if cld == "0,0" then return -- No heartbeating, per client
    if srd == "0,0" then return -- No heartbeating, per broker
    --
    ca = cld~makeArray(",")
    sa = srd~makeArray(",")
    --
    cx = ca~at(1)
    cy = ca~at(2)
    sx = sa~at(1)
    sy = sa~at(2)
    --
    -- say time("L") "cxcy:" cx cy
    -- say time("L") "sxsy:" sx sy
    --
    if cx <> 0 & sy <> 0 then do
        wms = cx
        if sy > wms then wms = sy
        runw = .true
    end
    --
    if sx <> 0 & cy <> 0 then do
        rms = sx
        if cy > rms then rms = cy
        runr = .true
    end
    --
    rsecs = 1.0 * rms / 1000.0
    wsecs = 1.0 * wms / 1000.0
    --
    rfz = (rms * 15) / 100
    wfz = (wms * 15) / 100


::method pp public
    expose runr runw lr lw rms wms rsecs wsecs wc
    use strict arg t
    --
    say time("L") t
    if runr then x = "true"
    else x = "false"
    say time("L") "Heartbeat Reads:" x
    if runw then x = "true"
    else x = "false"
    say time("L") "Heartbeat Writes:" x
    --
    say time("L") "Heartbeat Last Read:" lr
    say time("L") "Heartbeat Last Write:" lw
    --
    say time("L") "Heartbeat Read Interval (ms):" rms
    say time("L") "Heartbeat Write Interval (ms):" wms
    say time("L") "Heartbeat Read Interval (secs):" rsecs
    say time("L") "Heartbeat Write Interval (secs):" wsecs
    say time("L") "Heartbeat Write Count:" wc
