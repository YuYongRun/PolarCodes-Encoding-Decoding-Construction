# PolarCodes-Encoding-Decoding-Construction
Polar codes MATLAB implementations, incuding encoder, several types of SC decoder, CRC-SCL decoder and many code construction algorithms.

I am not a native English speaker so there may be errors in grammar or typo in these documents or the MATLAB codes.

This is fast MATLAB code for polar codes block error (BLER) performance estimation.

Comments are writen in the main.m. Here I just remind you some characteristics of these codes.

1. The famous recursive functions in SC decoding, i.e., recursiveCalcP() and recursiveCalcB() are not used here because too many parameters need to be passed during recursion, which makes MATLAB slow. Instead, I just use "for i = some inices" to replace above two functions. 
2. The polar encoder is writen in a "SC deocding style" to accelarate the simulation process. You may not see recursive functiona in this encoder.
3. I have used some accelaration methods in this MATLAB code. The details are writen in the comments in main.m. If you do not believe in my methods, you can just remove the corresponding MATLAB codes (and then get 'pure' codes without any accelaration). Even without my accelaration methods, this MATLAB code is still fast.
4. Several polar code construction algorithms are also given. These algorithms are state-of-art and yields good codes. ALL these algorithms can be found in IEEE Xplore. If you are not familar with polar code construction, you can search them in IEEE, for example, "How to construct polar code".

If you find there are obvious errors or probelms in my MATLAB codes, you may e-mail me 498699845@qq.com. Let us study polar codes together. I am just a student who is struggling for a Master degree.
