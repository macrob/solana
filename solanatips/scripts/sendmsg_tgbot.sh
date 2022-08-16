#!/bin/bash

telegram_bot_token="1854380631:AAF6i9WH6KnEGeksiCM9EXKmZmCEIho-Thg"
telegram_chat_id="43521637"

Title="$1"
Message="$2"

curl -s \
 --data parse_mode=HTML \
 --data chat_id=${telegram_chat_id} \
 --data text="<b>${Title}</b>%0A${Message}" \
 --request POST https://api.telegram.org/bot${telegram_bot_token}/sendMessage
