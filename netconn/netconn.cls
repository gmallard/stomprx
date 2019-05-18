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
-- Net Connection Helper
--
::class netConn public
--
-- Get and return a streaming network Connection
--
::method open public class
    use strict arg propfile

    -- Defaults
    host = "localhost"
    port = '61613'

    -- Overrides from properties file
    if propfile \= .nil then do
        if .strutls~isFile(propfile) then do
            mp = .properties~load(propfile)
            th = mp~getProperty("host", "")
            if th \= "" then
                host = th
            tp = mp~getProperty("port", "")
            if tp \= "" then
                port = tp
        end
    end

    -- Overrides from the environment
    x = value("STOMP_HOST",,"ENVIRONMENT")
    if x \= "" then
        host = x
    x = value("STOMP_PORT",,"ENVIRONMENT")
    if x \= "" then
        port = x

    --
    ssock = .streamsocket~new(host, port)
    ret = ssock~open
    if ret \= 'READY:'
    then do
        say 'Connection Failed:' ret
        return "ERROR: connect failed:" ret
    end
    --
    return ssock
--

::requires "../lib/strutls.rex"
::requires 'streamsocket.cls'
