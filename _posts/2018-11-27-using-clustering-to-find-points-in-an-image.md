---
title: "Using clustering to find points in an image"

author: "Florian Privé"
date: "November 27, 2018"
layout: post
---


<section class="main-content">
<p>In this post, I present my new <a href="https://github.com/privefl/img2coord">package {img2coord}</a>. This package can be used to retrieve coordinates from a scatter plot (as an image).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">devtools<span class="op">::</span><span class="kw">install_github</span>(<span class="st">&quot;privefl/img2coord&quot;</span>)</code></pre></div>
<p>Have you ever made a plot, saved it as a png and moved on? When you come back to it, it is sometimes difficult to read the values from this plot, especially if there is no grid inside the plot.<br />
Making this package was also a good way to practice with clustering.</p>
<div id="a-very-simple-example" class="section level2">
<h2>A very simple example</h2>
<div id="saving-a-plot-as-png" class="section level3">
<h3>Saving a plot as PNG</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">file &lt;-<span class="st"> </span><span class="kw">tempfile</span>(<span class="dt">fileext =</span> <span class="st">&quot;.png&quot;</span>)
<span class="kw">png</span>(file, <span class="dt">width =</span> <span class="dv">600</span>, <span class="dt">height =</span> <span class="dv">400</span>)
<span class="kw">set.seed</span>(<span class="dv">1</span>)
<span class="kw">plot</span>(<span class="kw">c</span>(<span class="dv">0</span>, <span class="kw">runif</span>(<span class="dv">20</span>), <span class="dv">1</span>))
<span class="kw">dev.off</span>()</code></pre></div>
<pre><code>## png 
##   2</code></pre>
</div>
<div id="reading-the-png-in-r" class="section level3">
<h3>Reading the PNG in R</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">(img &lt;-<span class="st"> </span>magick<span class="op">::</span><span class="kw">image_read</span>(file))</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-3-1.png" width="80%" style="display: block; margin: auto;" /></p>
</div>
<div id="get-pixel-indices-from-points" class="section level3">
<h3>Get pixel indices from points</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">## grayscale
img_mat &lt;-<span class="st"> </span>img2coord<span class="op">:::</span><span class="kw">img2mat</span>(img)
<span class="kw">dim</span>(img_mat)</code></pre></div>
<pre><code>## [1] 400 600</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">list.contour &lt;-<span class="st"> </span>img2coord<span class="op">:::</span><span class="kw">get_contours</span>(img_mat)
img_mat_in &lt;-<span class="st"> </span>img2coord<span class="op">:::</span><span class="kw">get_inside</span>(img_mat, list.contour)
<span class="kw">dim</span>(img_mat_in)</code></pre></div>
<pre><code>## [1] 264 507</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">head</span>(ind &lt;-<span class="st"> </span><span class="kw">which</span>(img_mat_in <span class="op">&gt;</span><span class="st"> </span><span class="dv">0</span>, <span class="dt">arr.ind =</span> <span class="ot">TRUE</span>))</code></pre></div>
<pre><code>##      row col
## [1,] 256  14
## [2,] 257  14
## [3,] 254  15
## [4,] 255  15
## [5,] 256  15
## [6,] 257  15</code></pre>
</div>
<div id="cluster-pixel-indices" class="section level3">
<h3>Cluster pixel indices</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">set.seed</span>(<span class="dv">1</span>)
km &lt;-<span class="st"> </span><span class="kw">kmeans</span>(ind, <span class="dt">centers =</span> <span class="dv">22</span>)</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(ggplot2)
myplot &lt;-<span class="st"> </span><span class="cf">function</span>(points, centers) {
  p &lt;-<span class="st"> </span><span class="kw">ggplot</span>() <span class="op">+</span><span class="st"> </span>
<span class="st">    </span><span class="kw">geom_tile</span>(<span class="kw">aes</span>(col, row), <span class="dt">data =</span> <span class="kw">as.data.frame</span>(points)) <span class="op">+</span><span class="st"> </span>
<span class="st">    </span><span class="kw">geom_point</span>(<span class="kw">aes</span>(col, row), <span class="dt">data =</span> <span class="kw">as.data.frame</span>(centers), <span class="dt">col =</span> <span class="st">&quot;red&quot;</span>) <span class="op">+</span><span class="st"> </span>
<span class="st">    </span>bigstatsr<span class="op">::</span><span class="kw">theme_bigstatsr</span>() <span class="op">+</span><span class="st"> </span>
<span class="st">    </span><span class="kw">coord_equal</span>()
  <span class="kw">print</span>(p)
}
<span class="kw">myplot</span>(ind, km<span class="op">$</span>centers)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-8-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>Even when using the true number of clusters, <em>kmeans</em> get trapped in a local minimum (this is clearly not the best solution!), depending on the initialisation of centers. One possible solution would be to use many initialisations; let’s try that.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">set.seed</span>(<span class="dv">1</span>)
km &lt;-<span class="st"> </span><span class="kw">kmeans</span>(ind, <span class="dt">centers =</span> <span class="dv">22</span>, <span class="dt">nstart =</span> <span class="dv">100</span>, <span class="dt">iter.max =</span> <span class="dv">100</span>)</code></pre></div>
<pre><code>## Warning: did not converge in 100 iterations

## Warning: did not converge in 100 iterations</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">myplot</span>(ind, km<span class="op">$</span>centers)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-9-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>It is better but not optimal.</p>
</div>
<div id="using-hclust-to-get-centers" class="section level3">
<h3>Using hclust to get centers</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">get_centers &lt;-<span class="st"> </span><span class="cf">function</span>(points, clusters) {
  <span class="kw">do.call</span>(<span class="st">&quot;rbind&quot;</span>, <span class="kw">by</span>(points, clusters, colMeans, <span class="dt">simplify =</span> <span class="ot">FALSE</span>))
}

d &lt;-<span class="st"> </span><span class="kw">dist</span>(ind)
hc &lt;-<span class="st"> </span><span class="kw">hclust</span>(d)
centers &lt;-<span class="st"> </span><span class="kw">get_centers</span>(ind, <span class="kw">cutree</span>(hc, <span class="dt">k =</span> <span class="dv">22</span>))
<span class="kw">myplot</span>(ind, centers)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-10-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p><code>hclust()</code> works well for this example.</p>
</div>
<div id="get-the-number-of-clusters" class="section level3">
<h3>Get the number of clusters</h3>
<p>What if we don’t know the number of clusters (representing the initial points)? A statistic that could help us determine the number of clusters to use is the silhouette.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">K_seq &lt;-<span class="st"> </span><span class="kw">seq</span>(<span class="dv">10</span>, <span class="dv">30</span>)
stat &lt;-<span class="st"> </span><span class="kw">sapply</span>(K_seq, <span class="cf">function</span>(k) {
  <span class="kw">mean</span>(cluster<span class="op">::</span><span class="kw">silhouette</span>(<span class="kw">cutree</span>(hc, k), d)[, <span class="dv">3</span>])
})
<span class="kw">plot</span>(K_seq, stat, <span class="dt">pch =</span> <span class="dv">20</span>); <span class="kw">abline</span>(<span class="dt">v =</span> <span class="dv">22</span>, <span class="dt">lty =</span> <span class="dv">3</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-11-1.png" width="80%" style="display: block; margin: auto;" /></p>
</div>
</div>
<div id="a-less-simple-example" class="section level2">
<h2>A less simple example</h2>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">file &lt;-<span class="st"> </span><span class="kw">tempfile</span>(<span class="dt">fileext =</span> <span class="st">&quot;.png&quot;</span>)
<span class="kw">png</span>(file, <span class="dt">width =</span> <span class="dv">600</span>, <span class="dt">height =</span> <span class="dv">400</span>)
<span class="kw">set.seed</span>(<span class="dv">1</span>)
y &lt;-<span class="st"> </span><span class="kw">c</span>(<span class="dv">0</span>, <span class="kw">runif</span>(<span class="dv">100</span>), <span class="dv">1</span>)
<span class="kw">plot</span>(y, <span class="dt">cex =</span> <span class="kw">runif</span>(<span class="dv">102</span>, <span class="dt">min =</span> <span class="fl">0.5</span>, <span class="dt">max =</span> <span class="fl">1.5</span>))
<span class="kw">dev.off</span>()</code></pre></div>
<pre><code>## png 
##   2</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">(img &lt;-<span class="st"> </span>magick<span class="op">::</span><span class="kw">image_read</span>(file))</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-13-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">img_mat &lt;-<span class="st"> </span>img2coord<span class="op">:::</span><span class="kw">img2mat</span>(img)
list.contour &lt;-<span class="st"> </span>img2coord<span class="op">:::</span><span class="kw">get_contours</span>(img_mat)
img_mat_in &lt;-<span class="st"> </span>img2coord<span class="op">:::</span><span class="kw">get_inside</span>(img_mat, list.contour)
ind &lt;-<span class="st"> </span><span class="kw">which</span>(img_mat_in <span class="op">&gt;</span><span class="st"> </span><span class="dv">0</span>, <span class="dt">arr.ind =</span> <span class="ot">TRUE</span>)</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">hc &lt;-<span class="st"> </span>flashClust<span class="op">::</span><span class="kw">hclust</span>(d &lt;-<span class="st"> </span><span class="kw">dist</span>(ind))
K_seq &lt;-<span class="st"> </span><span class="kw">seq</span>(<span class="dv">50</span>, <span class="dv">150</span>)
stat &lt;-<span class="st"> </span><span class="kw">sapply</span>(K_seq, <span class="cf">function</span>(k) {
  <span class="kw">mean</span>(cluster<span class="op">::</span><span class="kw">silhouette</span>(<span class="kw">cutree</span>(hc, k), d)[, <span class="dv">3</span>])
})
<span class="kw">plot</span>(K_seq, stat, <span class="dt">pch =</span> <span class="dv">20</span>); <span class="kw">abline</span>(<span class="dt">v =</span> <span class="dv">102</span>, <span class="dt">lty =</span> <span class="dv">3</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-15-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">(K_opt &lt;-<span class="st"> </span>K_seq[<span class="kw">which.max</span>(stat)])</code></pre></div>
<pre><code>## [1] 85</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">centers &lt;-<span class="st"> </span><span class="kw">get_centers</span>(ind, <span class="kw">cutree</span>(hc, <span class="dt">k =</span> K_opt))
<span class="kw">myplot</span>(ind, centers)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-16-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>The silhouette statistic is giving a good yet not optimal solution in this situation. Using the true number of points, we would get:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">centers &lt;-<span class="st"> </span><span class="kw">get_centers</span>(ind, <span class="kw">cutree</span>(hc, <span class="dt">k =</span> <span class="dv">102</span>))
<span class="kw">myplot</span>(ind, centers)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-17-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>If someone has a better statistic to (automatically) find the number of clusters, please share it and I’ll update this post.</p>
</div>
<div id="putting-everything-together-as-a-package" class="section level2">
<h2>Putting everything together as a package</h2>
<p>Finally, after you get the center of all points (pixel clusters), you can interpolate the values based on the values of axe ticks.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">coord &lt;-<span class="st"> </span>img2coord<span class="op">::</span><span class="kw">get_coord</span>(
  file, 
  <span class="dt">x_ticks =</span> <span class="kw">seq</span>(<span class="dv">0</span>, <span class="dv">100</span>, <span class="dv">20</span>),
  <span class="dt">y_ticks =</span> <span class="kw">seq</span>(<span class="dv">0</span>, <span class="dv">1</span>, <span class="fl">0.2</span>),
  <span class="dt">K_min =</span> <span class="dv">50</span>, <span class="dt">K_max =</span> <span class="dv">150</span>
) </code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-18-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>This works better here because I combined the silhouette statistic with a gini coefficient (measure of dispersion) of the number of pixels in each cluster (assuming that they should have approximately the same number). Let’s have a look at the combined statistic:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">stat &lt;-<span class="st"> </span><span class="kw">attr</span>(coord, <span class="st">&quot;stat&quot;</span>)
<span class="kw">plot</span>(<span class="kw">names</span>(stat), stat, <span class="dt">pch =</span> <span class="dv">20</span>); <span class="kw">abline</span>(<span class="dt">v =</span> <span class="dv">102</span>, <span class="dt">lty =</span> <span class="dv">3</span>) </code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-19-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>If you don’t get the right number of clusters the first time, you can use the plot generated by <code>img2coord::get_coord()</code> to adjust <code>K</code>.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">coord &lt;-<span class="st"> </span>img2coord<span class="op">::</span><span class="kw">get_coord</span>(
  file, 
  <span class="dt">x_ticks =</span> <span class="kw">seq</span>(<span class="dv">0</span>, <span class="dv">100</span>, <span class="dv">20</span>),
  <span class="dt">y_ticks =</span> <span class="kw">seq</span>(<span class="dv">0</span>, <span class="dv">1</span>, <span class="fl">0.2</span>),
  <span class="dt">K =</span> <span class="dv">102</span>  ## 99 + 3
) </code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-20-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>Let’s verify the coordinates we get:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">round</span>(coord<span class="op">$</span>x, <span class="dv">2</span>)</code></pre></div>
<pre><code>##   [1]   1.00   2.01   3.01   4.00   4.99   6.01   7.00   8.00   9.01  10.01
##  [11]  10.98  11.99  12.99  14.01  15.00  15.98  17.01  18.00  18.98  20.00
##  [21]  20.99  22.00  23.00  23.99  24.98  26.00  26.99  28.01  29.00  29.98
##  [31]  31.01  31.99  33.02  34.00  35.02  35.98  37.00  38.01  38.99  40.00
##  [41]  40.99  41.99  42.99  44.01  44.97  45.98  47.01  48.00  49.00  50.00
##  [51]  51.01  51.98  52.99  53.99  55.00  56.00  57.01  58.01  59.00  60.02
##  [61]  61.00  62.00  62.98  64.01  64.99  65.98  67.00  68.01  68.98  70.00
##  [71]  70.98  72.00  73.00  74.01  75.00  76.01  77.00  78.00  79.02  79.98
##  [81]  81.00  82.01  82.98  84.00  85.01  85.99  87.01  87.98  88.99  89.99
##  [91]  90.98  92.00  93.00  94.01  95.00  95.89  96.87  97.99  99.00 100.00
## [101] 101.01 101.99</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">plot</span>(coord<span class="op">$</span>y, y, <span class="dt">pch =</span> <span class="dv">20</span>); <span class="kw">abline</span>(<span class="dv">0</span>, <span class="dv">1</span>, <span class="dt">col =</span> <span class="st">&quot;red&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-21-1.png" width="80%" style="display: block; margin: auto;" /></p>
</div>
<div id="handling-large-images" class="section level2">
<h2>Handling large images</h2>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">url &lt;-<span class="st"> &quot;https://goo.gl/K6Y7D1&quot;</span>
<span class="kw">library</span>(img2coord)
(img &lt;-<span class="st"> </span><span class="kw">img_read</span>(url))</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-22-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">get_coord</span>(img, <span class="kw">seq</span>(<span class="dv">0</span>, <span class="dv">20</span>, <span class="dv">5</span>), <span class="kw">seq</span>(<span class="dv">94</span>, <span class="dv">102</span>, <span class="dv">2</span>), <span class="dt">K_min =</span> <span class="dv">40</span>, <span class="dt">K_max =</span> <span class="dv">80</span>)</code></pre></div>
<pre><code>## Error: Detected more than 10000 pixels associated with points (21358).
##   Make sure you have a white background with no grid (only points).
##   You can change &#39;max_pixels&#39;, but it could become time/memory consuming.
##   You can also downsize the image using `img_scale()`.</code></pre>
<p>The green points are spanning 21,358 pixels, which could be a lot to process, depending on your computer. To solve this problem, you can do:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">img <span class="op">%&gt;%</span>
<span class="st"> </span><span class="kw">img_scale</span>(<span class="fl">0.4</span>) <span class="op">%&gt;%</span>
<span class="st"> </span><span class="kw">get_coord</span>(<span class="kw">seq</span>(<span class="dv">0</span>, <span class="dv">20</span>, <span class="dv">5</span>), <span class="kw">seq</span>(<span class="dv">94</span>, <span class="dv">102</span>, <span class="dv">2</span>), <span class="dt">K_min =</span> <span class="dv">40</span>, <span class="dt">K_max =</span> <span class="dv">80</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-cluster-points_files/figure-html/unnamed-chunk-24-1.png" width="80%" style="display: block; margin: auto;" /></p>
<pre><code>## $x
##  [1] -0.0005401687  0.3343468897  0.6664667098  0.9992303467  1.3337481120
##  [6]  1.6671560578  1.9997172265  2.3332269701  2.6674887594  2.9991939098
## [11]  3.3326859175  3.6672015650  4.0000566377  4.3329094030  4.6674459579
## [16]  5.0009192485  5.3326185095  5.6478368286  6.0464367945  6.3329501844
## [21]  6.6663573828  6.9839799351  7.3513525635  7.6674682785  8.0006621331
## [26]  8.3329974666  8.6657575234  8.9999189758  9.3339407034  9.6666009658
## [31] 10.0001231324 10.3173252500 10.6778169496 10.9989528978 11.3335964907
## [36] 11.6665738876 11.9994145980 12.3336165187 12.6676553366 12.9992455320
## [41] 13.3331964821 13.6668686496 13.9813979399 14.3425396058 14.6672323938
## [46] 15.0002253318 15.3330976683 15.6669750015 16.0007098735 16.3322818494
## [51] 16.6663301257 17.0005035442 17.3333809139 17.6663416006 18.0009680691
## [56] 18.3172429708 18.6798897677 18.9998067488 19.3333374006 19.6570288544
## [61] 20.0116006657
## 
## $y
##  [1] 103.18007 101.68089 102.91175 101.28109 100.89144 100.36108  98.59931
##  [8]  99.06933  99.90900  98.61988 100.39017  96.87960 100.38054  97.52969
## [15] 101.77948  98.63014  99.10885  98.62457  98.58221  99.06001  99.97088
## [22]  99.09976  98.96014  98.68939  99.77109  98.78963  95.94976  97.51865
## [29]  97.07733  96.58967  98.21105  98.69922  98.53481  97.74167  97.24962
## [36]  97.65023  98.70168  99.77109  97.02095  94.91963  97.65023  96.46068
## [43]  95.23798  95.39595  94.64729  93.14815  95.35968  95.04774  95.82991
## [50]  94.43923  94.96829  96.84944  93.94962  93.35852  97.42928  94.07914
## [57]  94.23708  97.51029  95.68894  94.35497  94.16229
## 
## attr(,&quot;stat&quot;)
##        40        41        42        43        44        45        46 
##  1.991872  2.074327  2.140775  2.270267  2.341965  2.529008  2.758398 
##        47        48        49        50        51        52        53 
##  2.920247  3.119059  3.244979  3.377485  3.715905  4.083564  4.563417 
##        54        55        56        57        58        59        60 
##  5.104999  5.841044  6.441349  6.551265  7.246189  8.165916  8.842711 
##        61        62        63        64        65        66        67 
## 10.167292  8.357433  6.887889  5.708635  4.889674  4.274374  3.788661 
##        68        69        70        71        72        73        74 
##  3.384619  3.082882  2.836479  2.630589  2.451460  2.292444  2.162840 
##        75        76        77        78        79        80 
##  2.054934  1.947805  1.870104  1.784646  1.701550  1.630990</code></pre>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>We have seen that <code>hclust()</code> was performing better than <code>kmeans()</code> (for this example). For some reason I don’t understand yet, initializing <code>kmeans()</code> with centers from <code>hclust()</code> works even better.</p>
<p>Then, we have seen how to determine the number of clusters. Finally, we have seen that using a particular statistic, specifically designed for this problem, improved the solution.</p>
<p>Of course, this could be improved a lot. For example, this won’t work for plots having a background color or some grid inside. Feel free to bring your ideas. BTW, thanks <a href="https://twitter.com/robincura">Robin</a> who brought some nice ideas that improved this package a lot.</p>
<p>Have a look at <a href="https://github.com/privefl/img2coord">the GitHub repo</a>.</p>
</div>
</section>
