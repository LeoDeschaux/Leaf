@echo off
title Python Server

start browser-sync start --server --files "index.wasm" --index "index.html" --port 8000

exit