@echo off
for /r %%i in (sudokus\*.txt) do perl sudoku_solver.pl %%i
