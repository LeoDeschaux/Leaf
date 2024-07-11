@echo off
title Python Server
start "" python -m http.server
start "" http://localhost:8000/index.html