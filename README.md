# Gaussian Mixture Models (GMM)

This is an implementation of Gaussian Mixture Models (GMM) on Matlab.

This implementation is based on Stuffer's and Grisomn's paper in [1]. They have introduced a new method for realtime segmentation that is robust and flexible to noise and perform better in modelling dynamic backgrounds. Common methods for real-time segmentation like "background subtraction" are vulnerable to changes in the background. For example, if there were some clouds on the sky or it is windy or raining, the standard methods have no chance to update their model or overcome this issue, thus giving wrong results. However, Stuffer’s and Grisomn’s approach is capable to cope such issues.

Simply their approach is to model the values of each pixel as a mixture of Gaussian distributions; then based on the variance and supporting statistics of the models we decide either a pixel is background or foreground. These characteristics allow the approach to have more than one possible pixel intensity that corresponds to the background. Furthermore, at each frame, Gaussians of mixtures at a pixel are either reinforced, punished or replaced, giving the background an advantage to improve and reduce error measurements. 

The following three videos are samples of the results obtained by the code. Click on the images to watch the video on YouTube.

[<p align="center"> <img src="https://img.youtube.com/vi/UdRa-q5qbfo/0.jpg" width="50%" title="GMM sample video 1, click to watch" > </p>](https://youtu.be/UdRa-q5qbfo)

<p align="center">
    <em>Gaussian Mixture Models (GMM) Output Sample 1</em>
</p>

[<p align="center"> <img src="https://img.youtube.com/vi/iyzrvn_z9PE/0.jpg" width="50%" title="GMM sample video 2, click to watch"> </p>](https://youtu.be/iyzrvn_z9PE)
 
 <p align="center">
    <em>Gaussian Mixture Models (GMM) Output Sample 2</em>
</p>

[<p align="center"> <img src="https://img.youtube.com/vi/jKeRerl0PuQ/0.jpg" width="50%" title="GMM sample video 3, click to watch"> </p>](https://youtu.be/jKeRerl0PuQ)

<p align="center">
    <em>Gaussian Mixture Models (GMM) Output Sample 3</em>
</p>


The following block diagram illustrates the followed approach:

<p align="center">
<img src="https://user-images.githubusercontent.com/35075754/156894262-251e05ae-8b5d-4178-8c0c-f1bf19cd3900.jpg" width="400">
</p>

The process is further illustrated in the following pseudocode:

```
V ← video input
while V has frames do
|  for all pixels do
|  |  label background model
|  |  for all distributions in pixel do
|  |  |  if pixel intensity match the distribution then
|  |  |  |  label the pixel
|  |  |  |  update distribution’s w, µ and σ
|  |  |  else if intensity didn’t match the distribution then
|  |  |  |  update distribution’s w
|  |  |  end if
|  |  end for
|  |  if intensity didn’t match any of the distributions then
|  |  |  replace the distribution with the least w/σ
|  |  end if
|  end for
|  show the binary mask
|  show the current background model by printing the µ of the
|  highest w\σ for each pixel individually
end while
```




> ArgMinimum() is made to label the distributions as foregound or
 background. It will return two arrays, one contains the indices of the
 foreground and the other the indices of the background.

Citations:
[1] C. Stauffer and W. E. L. Grimson, "Adaptive background mixture models for real-time tracking," Proceedings. 1999 IEEE Computer Society Conference on Computer Vision and Pattern Recognition (Cat. No PR00149), 1999, pp. 246-252 Vol. 2, doi: [10.1109/CVPR.1999.784637].


[10.1109/CVPR.1999.784637]: <https://ieeexplore.ieee.org/document/784637>
