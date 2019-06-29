#!/usr/bin/env bash
#
set -x
rexx acknak_basic.rex
rexx connect_basic.rex
rexx frame_basic.rex
rexx hdrencdec.rex
rexx header_basic.rex
rexx headers_basic.rex
rexx headers_encdec.rex
rexx netconn_basic.rex
#
STOMP_DEST=/queue/rexx/test/recv/10 STOMP_NMSGS=1 rexx send_basic.rex
STOMP_DEST=/queue/rexx/test/recv/10nid STOMP_NMSGS=1 rexx send_basic.rex
STOMP_DEST=/queue/rexx/test/recv/11 STOMP_NMSGS=1 rexx send_basic.rex
STOMP_DEST=/queue/rexx/test/recv/12 STOMP_NMSGS=1 rexx send_basic.rex
rexx recv_basic.rex
#
STOMP_DEST=/queue/rexx/test/recv/12 STOMP_NMSGS=1 rexx send_basic.rex
rexx recvsq_basic.rex
#
### rexx send_basic.rex
#
rexx stc_basic.rex
rexx subscription_basic.rex
rexx sun_basic.rex
rexx trn_basic.rex
rexx tstrutls.rex
rexx uuid_basic.rex
set +x
