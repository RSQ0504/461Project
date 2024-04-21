myfun = @() main2();
time = timeit(myfun);
fprintf("-------total time %2.2f", time);