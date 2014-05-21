SillyAnimtor
============

This simple and crude tool was created while working with a friend whom is affectionately a Silly Animator. 

First Feature:
My Silly Animator I work with exports frames with the format ImageName0001.png ... ImageName0100.png. When loading these images to a Texture Atlas is Sprite Kit, I have to use a separate for loop for each power of 10. Namely:

 [NSString stringWithFormat:@"ImageName000%d.png", i] where i = 1;   Output: ImageName0001.png
 [NSString stringWithFormat:@"ImageName000%d.png", i] where i = 100: OutPut: ImageName000100.png

I would have to embed power of 10 conditions in the loop, and output the string with such contingencies.

Silly Animator turns a set of ImageName0001.png ... ImageName0100.png into simply ImageName1.png ... ImageName100.png


Second Feature:
Perfectly crop an image.
My Silly Animator uses Adobe Flash for animating. He exports dimensionally huge images that are mostly whitespace transparency.
The image crop feature takes the minimum rectangle around images. Perfectly. Every time.
