/*
 Copyright © 2019 Guy M. Allard

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliasockete with the License.
 You may obtain a copy of the License at

     http:www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

/* Purley for the constants.  No init method provided. */
::class stc public

/* Client generated frame commands */
::constant CONNECT      "CONNECT"
::constant STOMP        "STOMP"
::constant DISCONNECT   "DISCONNECT"
::constant SEND         "SEND"
::constant SUBSCRIBE    "SUBSCRIBE"
::constant UNSUBSCRIBE  "UNSUBSCRIBE"
::constant ACK          "ACK"
::constant NACK         "NACK"
::constant BEGIN        "BEGIN"
::constant COMMIT       "COMMIT"
::constant ABORT        "ABORT"
/* Broker generated frame commands */
::constant CONNECTED    "CONNECTED"
::constant MESSAGE      "MESSAGE"
::constant RECEIPT      "RECEIPT"
::constant ERROR        "ERROR"

/* Supported STOMP protocol definitions. */
::constant SPL_10  "1.0"
::constant SPL_11  "1.1"
::constant SPL_12  "1.2"

/* COmmon header keys */
::constant 	HK_ACCEPT_VERSION  "accept-version"
::constant 	HK_ACK             "ack"
::constant 	HK_CONTENT_TYPE    "content-type"
::constant 	HK_CONTENT_LENGTH  "content-length"
::constant 	HK_DESTINATION     "destination"
::constant 	HK_HEART_BEAT      "heart-beat"
::constant 	HK_HOST            "host"
::constant 	HK_ID              "id"
::constant 	HK_LOGIN           "login"
::constant 	HK_MESSAGE         "message"
::constant 	HK_MESSAGE_ID      "message-id"
::constant 	HK_SUPPRESS_CL     "suppress-content-length"
::constant 	HK_SUPPRESS_CT     "suppress-content-type"
::constant 	HK_PASSCODE        "passcode"
::constant 	HK_RECEIPT         "receipt"
::constant 	HK_RECEIPT_ID      "receipt-id"
::constant 	HK_SESSION         "session"
::constant 	HK_SERVER          "server"
::constant 	HK_SUBSCRIPTION    "subscription"
::constant 	HK_TRANSACTION     "transaction"
::constant 	HK_VERSION         "version"
::constant 	HK_VHOST           "host"

/* Misc. */
