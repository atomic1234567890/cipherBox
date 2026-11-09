@echo off
title CipherBox - add Defender exclusion
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\add-exclusion.ps1"