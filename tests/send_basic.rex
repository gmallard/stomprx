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

asock = .netconn~open(.nil)
ch = .headers~connhdr10
cod = .directory~new
sc = .stomprxconn~new(asock, ch, cod)
--
startmsg = 1
nmsg = value("STOMP_NMSGS", "", .stc~env)
if nmsg == "" then nmsg = 2500
-- Pattern headers
sh = .headers~new
d = value("STOMP_DEST", "", .stc~env)
if d == "" then d = "/queue/rexx.send"
t = .header~new(.stc~HK_DESTINATION, d)
sh~add(t)
t = .header~new(.stc~HK_CONTENT_TYPE, "text/plain; charset=UTF-8")
sh~add(t)
rpart = "12345678901234567890"
say time("L") "send test starts"
mc = 0
do i = startmsg to nmsg
    mc = mc + 1
    rp = rpart~substr(1, random(1,20))
    om = "Message" i rp
    say "send test message:" mc om~length om
    useh = sh~clone -- clone pattern
    t = .header~new(.stc~HK_CONTENT_LENGTH, om~length)
    useh~add(t)    
    t = .header~new("srx_mid", mc)
    useh~add(t)    
    -- useh~pp("Send Headers App:")

    rc = sc~send(useh, om)
    if rc < 0 then
        say "send failed:" rc
    
    ef = sc~recverr
    if ef <> .nil then do
        say "error frame received from broker"
        ef~pp("ERROR Frame is:")
        sc~disconnect
        exit
    end
    
end
dh = .headers~new
rc = .header~new(.stc~HK_RECEIPT, "send.receipt.id")
dh~add(rc)
sc~disconnect(dh)
rf = sc~recvrcpt(0.3)
rf~pp("RECEIPT Frame:")

say "send test done"
--
::requires "../stomprx.cls"
