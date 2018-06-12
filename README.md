There are countless MATLAB codes for polar codes. Why you should at least download and run my MATLAB codes? Well, firstly, this code is relatively fast. Secondly, many additional code construction algorithms are provided here, including GA, channel up/degrading method and something else.

Polar codes MATLAB implementations, including encoder, several types of SC decoder, CRC-SCL decoder and many code construction algorithms.
I am not a native English speaker so there may be errors in grammar or typo in these documents or the MATLAB codes.

This is fast MATLAB code for polar codes block error (BLER) performance estimation.

Comments are written in the main.m. Here I just remind you some characteristics of these codes.

1.	The famous recursive functions in SC decoding, i.e., recursiveCalcP() and recursiveCalcB() are not used here because too many parameters need to be passed during recursion, which makes MATLAB slow. Instead, I just use "for i = some indices" to replace above two functions.
2.	The polar encoder is written in a "SC decoding style" to accelerate the simulation process. You may not see recursive function in this encoder.
3.	I have used some acceleration methods in this MATLAB code. The details are written in the comments in main.m. If you do not believe in my methods, you can just remove the corresponding MATLAB codes (and then get 'pure' codes without any acceleration). Even without my acceleration methods, this MATLAB code is still fast.
4.	Several polar code construction algorithms are also given. These algorithms are state-of-art and yields good codes.

If you find there are obvious errors or problems in my MATLAB codes, you may e-mail me 498699845@qq.com. Let us study polar codes together. I am just a student who is struggling for a Master degree.
