/*
 * Copyright (c) 2019 Fastly, Kazuho Oku
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

/**
 * Providers of quicly. Name of the arguments are important - they are used as the names of JSON fields when the dtrace script is
 * generated.
 */
provider quicly {
    probe connect(struct st_quicly_conn_t *conn, int64_t at, uint32_t version);
    probe accept(struct st_quicly_conn_t *conn, int64_t at, const char *dcid,
                 struct st_quicly_address_token_plaintext_t *address_token);
    probe free(struct st_quicly_conn_t *conn, int64_t at);
    probe send(struct st_quicly_conn_t *conn, int64_t at, int state, const char *dcid);
    probe receive(struct st_quicly_conn_t *conn, int64_t at, const char *dcid, const void *bytes, size_t num_bytes);
    probe version_switch(struct st_quicly_conn_t *conn, int64_t at, uint32_t new_version);
    probe idle_timeout(struct st_quicly_conn_t *conn, int64_t at);
    probe stateless_reset_receive(struct st_quicly_conn_t *conn, int64_t now);

    probe crypto_decrypt(struct st_quicly_conn_t *conn, uint64_t pn, const void *decrypted, size_t decrypted_len);
    probe crypto_handshake(struct st_quicly_conn_t *conn, int ret);
    probe crypto_update_secret(struct st_quicly_conn_t *conn, int is_enc, uint8_t epoch, const char *label, const char *secret);
    probe crypto_send_key_update(struct st_quicly_conn_t *conn, uint64_t phase, const char *secret);
    probe crypto_send_key_update_confirmed(struct st_quicly_conn_t *conn, uint64_t next_pn);
    probe crypto_receive_key_update(struct st_quicly_conn_t *conn, uint64_t phase, const char *secret);
    probe crypto_receive_key_update_prepare(struct st_quicly_conn_t *conn, uint64_t phase, const char *secret);

    probe packet_prepare(struct st_quicly_conn_t *conn, int64_t at, uint8_t first_octet, const char *dcid);
    probe packet_commit(struct st_quicly_conn_t *conn, int64_t at, uint64_t pn, size_t len, int ack_only);
    probe packet_acked(struct st_quicly_conn_t *conn, int64_t at, uint64_t pn, int newly_acked);
    probe packet_lost(struct st_quicly_conn_t *conn, int64_t at, uint64_t pn);

    probe pto(struct st_quicly_conn_t *conn, int64_t at, size_t inflight, uint32_t cwnd, int8_t pto_count);
    probe cc_ack_received(struct st_quicly_conn_t *conn, int64_t at, uint64_t largest_acked, size_t bytes_acked, uint32_t cwnd,
                          size_t inflight);
    probe cc_congestion(struct st_quicly_conn_t *conn, int64_t at, uint64_t max_lost_pn, size_t inflight, uint32_t cwnd);

    probe transport_close_send(struct st_quicly_conn_t *conn, int64_t at, uint64_t error_code, uint64_t frame_type,
                               const char *reason_phrase);
    probe transport_close_receive(struct st_quicly_conn_t *conn, int64_t at, uint64_t error_code, uint64_t frame_type,
                                  const char *reason_phrase);
    probe application_close_send(struct st_quicly_conn_t *conn, int64_t at, uint64_t error_code, const char *reason_phrase);
    probe application_close_receive(struct st_quicly_conn_t *conn, int64_t at, uint64_t error_code, const char *reason_phrase);

    probe stream_send(struct st_quicly_conn_t *conn, int64_t at, struct st_quicly_stream_t *stream, uint64_t off, size_t len,
                      int is_fin);
    probe stream_receive(struct st_quicly_conn_t *conn, int64_t at, struct st_quicly_stream_t *stream, uint64_t off, size_t len);
    probe stream_acked(struct st_quicly_conn_t *conn, int64_t at, int64_t stream_id, uint64_t off, size_t len);
    probe stream_lost(struct st_quicly_conn_t *conn, int64_t at, int64_t stream_id, uint64_t off, size_t len);

    probe max_data_send(struct st_quicly_conn_t *conn, int64_t at, uint64_t limit);
    probe max_data_receive(struct st_quicly_conn_t *conn, int64_t at, uint64_t limit);

    probe max_streams_send(struct st_quicly_conn_t *conn, int64_t at, uint64_t limit, int is_unidirectional);
    probe max_streams_receive(struct st_quicly_conn_t *conn, int64_t at, uint64_t limit, int is_unidirectional);

    probe max_stream_data_send(struct st_quicly_conn_t *conn, int64_t at, struct st_quicly_stream_t *stream, uint64_t limit);
    probe max_stream_data_receive(struct st_quicly_conn_t *conn, int64_t at, int64_t stream_id, uint64_t limit);

    probe new_cid_send(struct st_quicly_conn_t *conn, int64_t at, uint8_t seq, const char *pcid, uint64_t retire_prior_to, const char *token);
    probe new_cid_receive(struct st_quicly_conn_t *conn, int64_t at, uint8_t seq, const char *pcid, uint64_t retire_prior_to, const char *token);

    probe new_token_send(struct st_quicly_conn_t *conn, int64_t at, uint8_t *token, size_t len, uint64_t generation);
    probe new_token_acked(struct st_quicly_conn_t *conn, int64_t at, uint64_t generation);
    probe new_token_receive(struct st_quicly_conn_t *conn, int64_t at, uint8_t *token, size_t len);

    probe streams_blocked_send(struct st_quicly_conn_t *conn, int64_t at, uint64_t limit, int is_unidirectional);
    probe streams_blocked_receive(struct st_quicly_conn_t *conn, int64_t at, uint64_t limit, int is_unidirectional);

    probe data_blocked_receive(struct st_quicly_conn_t *conn, int64_t at, uint64_t off);

    probe stream_data_blocked_receive(struct st_quicly_conn_t *conn, int64_t at, int64_t stream_id, uint64_t limit);

    probe quictrace_sent(struct st_quicly_conn_t *conn, int64_t at, uint64_t pn, size_t len, uint8_t packet_type);
    probe quictrace_recv(struct st_quicly_conn_t *conn, int64_t at, uint64_t pn);
    probe quictrace_send_stream(struct st_quicly_conn_t *conn, int64_t at, struct st_quicly_stream_t *stream, uint64_t off,
                                size_t len, int fin);
    probe quictrace_send_datagram(struct st_quicly_conn_t *conn, int64_t at, size_t len);
    probe quictrace_recv_stream(struct st_quicly_conn_t *conn, int64_t at, int64_t stream_id, uint64_t off, size_t len, int fin);
    probe quictrace_recv_ack(struct st_quicly_conn_t *conn, int64_t at, uint64_t path_id, uint64_t ack_block_begin, uint64_t ack_block_end);
    probe quictrace_recv_ack_delay(struct st_quicly_conn_t *conn, int64_t at, int64_t ack_delay);
    probe quictrace_lost(struct st_quicly_conn_t *conn, int64_t at, uint64_t pn);
    probe quictrace_cc_ack(struct st_quicly_conn_t *conn, int64_t at, struct quicly_rtt_t *rtt, uint32_t cwnd, size_t inflight);
    probe quictrace_cc_lost(struct st_quicly_conn_t *conn, int64_t at, struct quicly_rtt_t *rtt, uint32_t cwnd, size_t inflight);
};
