my_complexity_32 = [
2.5      1092.9707
  3      737.96588
3.5      449.67982
  4      279.90317
4.5      183.82816
  5      134.6111
5.5      100.3284];

eng_complexity_32 = [
2.5      1209.9005
  3      790.76571
3.5      543.86195
  4      338.61662
4.5      234.50685
  5      172.1473
5.5      133.2997];

my_complexity_64 = [
2.5        85394.6486
  3         29057.7514 
3.5      14597.3673
  4       4505.9342
4.5       1634.406
  5      842.9156
5.5      422.8101];


eng_complexity_64 = [
2.5      141669.285
  3      48540.47
3.5      16282.9649
  4            5314.5053
4.5      1726.6078
  5      857.3893                       
5.5      403.9173];

semilogy(my_complexity_32(:, 1), [my_complexity_32(:, 2) eng_complexity_32(:, 2) my_complexity_64(:, 2) eng_complexity_64(:, 2)])
grid on

legend('initial radius method in [], P(32,22+6)',...
    'propsoed method in [], P(32,22+6)',...
    'initial radius method, P(64,32+8)',...
    'proposed method, P(64,32+8)'...
    )

xlabel('E_b/N_0 (dB)')
ylabel('Average complexity')
set(gca, 'Fontname', 'Times new roman', 'Fontsize', 11);
set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',1.15);


 