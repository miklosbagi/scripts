#!/bin/bash

# Dependencies: jq, openssl
# Tested on MacOS only

function base64url_encode() {
    openssl base64 -e -A | tr '+/' '-_' | tr -d '='
}

function base64url_decode() {
    local len=$((${#1} % 4))
    local result="$1"
    if [ $len -eq 2 ]; then result="$1"==; fi
    if [ $len -eq 3 ]; then result="$1"=; fi
    echo "$result" | openssl base64 -d -A
}

function encode_jwt() {
    local header="$1"
    local payload="$2"
    local secret="$3"

    local encoded_header=$(echo -n "$header" | base64url_encode)
    local encoded_payload=$(echo -n "$payload" | base64url_encode)
    local signature=$(echo -n "$encoded_header.$encoded_payload" | openssl dgst -sha256 -hmac "$secret" -binary | base64url_encode)

    echo "$encoded_header.$encoded_payload.$signature"
}

function decode_jwt() {
    local token="$1"

    IFS='.' read -ra parts <<< "$token"
    echo "Header:"
    base64url_decode "${parts[0]}" | jq
    echo "Payload:"
    base64url_decode "${parts[1]}" | jq
}

function show_help() {
    echo "Usage: $0 <action> <data...>"
    echo ""
    echo "Actions:"
    echo "  encode <header> <payload> <secret>   - Encode JWT using the provided header, payload, and secret."
    echo "  decode <token>                       - Decode the provided JWT token."
    echo "  help                                 - Show this help message."
    echo ""
    echo "Examples:"
    echo "  $0 encode '{\"alg\":\"HS256\",\"typ\":\"JWT\"}' '{\"sub\":\"1234567890\",\"name\":\"John Doe\",\"iat\":1516239022}' 'your_secret'"
    echo "  $0 decode 'your_jwt_token_here'"
}

function main() {
    local action="$1"

    case "$action" in
        encode|-encode)
            local header="$2"
            local payload="$3"
            local secret="$4"
            encode_jwt "$header" "$payload" "$secret"
            ;;
        decode|-decode)
            local token="$2"
            decode_jwt "$token"
            ;;
        help|-help|"")
            show_help
            ;;
        *)
            echo "Invalid action. Type '$0 help' for usage instructions."
            ;;
    esac
}

main "$@"

