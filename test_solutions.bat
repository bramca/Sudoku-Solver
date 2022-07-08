@echo off

for %%i in (*.txt) do (
    fc %%i solutions\%%i
)

