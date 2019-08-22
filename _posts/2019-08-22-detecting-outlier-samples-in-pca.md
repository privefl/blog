---
title: "Detecting outlier samples in PCA"

author: "Florian Privé"
date: "August 22, 2019"
layout: post
---


<section class="main-content">
<p>In this post, I present something I am currently investigating (feedback welcome!) and that I am implementing in my new <a href="https://github.com/privefl/bigutilsr">package {bigutilsr}</a>. This package can be used to detect outlier samples in Principal Component Analysis (PCA).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">remotes<span class="op">::</span><span class="kw">install_github</span>(<span class="st">&quot;privefl/bigutilsr&quot;</span>)</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(bigutilsr)</code></pre></div>
<p>I present three different statistics of outlierness and two different ways to choose the threshold of being an outlier for those statistics.</p>
<div id="a-standard-way-to-detect-outliers" class="section level2">
<h2>A standard way to detect outliers</h2>
<div id="data" class="section level3">
<h3>Data</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">X &lt;-<span class="st"> </span><span class="kw">readRDS</span>(<span class="kw">system.file</span>(<span class="st">&quot;testdata&quot;</span>, <span class="st">&quot;three-pops.rds&quot;</span>, <span class="dt">package =</span> <span class="st">&quot;bigutilsr&quot;</span>))
pca &lt;-<span class="st"> </span><span class="kw">prcomp</span>(X, <span class="dt">scale. =</span> <span class="ot">TRUE</span>, <span class="dt">rank. =</span> <span class="dv">10</span>)
U &lt;-<span class="st"> </span>pca<span class="op">$</span>x</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(ggplot2)
<span class="kw">theme_set</span>(bigstatsr<span class="op">::</span><span class="kw">theme_bigstatsr</span>(<span class="fl">0.8</span>))
<span class="kw">qplot</span>(U[, <span class="dv">1</span>], U[, <span class="dv">2</span>]) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>()</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-4-1.png" width="70%" style="display: block; margin: auto;" /></p>
</div>
<div id="measuring-outlierness" class="section level3">
<h3>Measuring outlierness</h3>
<p>The standard way to detect outliers in genetics is the criterion of being “more than 6 standard deviations away from the mean”.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">apply</span>(U, <span class="dv">2</span>, <span class="cf">function</span>(x) <span class="kw">which</span>( <span class="kw">abs</span>(x <span class="op">-</span><span class="st"> </span><span class="kw">mean</span>(x)) <span class="op">&gt;</span><span class="st"> </span>(<span class="dv">6</span> <span class="op">*</span><span class="st"> </span><span class="kw">sd</span>(x)) ))</code></pre></div>
<pre><code>## integer(0)</code></pre>
<p>Here, there is no outlier according to this criterion. Let us make some fake one.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">U2 &lt;-<span class="st"> </span>U
U2[<span class="dv">1</span>, <span class="dv">1</span>] &lt;-<span class="st"> </span><span class="dv">30</span>
<span class="kw">qplot</span>(U2[, <span class="dv">1</span>], U2[, <span class="dv">2</span>]) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>()</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-6-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">apply</span>(U2, <span class="dv">2</span>, <span class="cf">function</span>(x) <span class="kw">which</span>( <span class="kw">abs</span>(x <span class="op">-</span><span class="st"> </span><span class="kw">mean</span>(x)) <span class="op">&gt;</span><span class="st"> </span>(<span class="dv">6</span> <span class="op">*</span><span class="st"> </span><span class="kw">sd</span>(x)) ))</code></pre></div>
<pre><code>## integer(0)</code></pre>
<p>Still not an outlier..</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">U3 &lt;-<span class="st"> </span>U2
U3[<span class="dv">1</span>, <span class="dv">1</span>] &lt;-<span class="st"> </span><span class="dv">80</span>
<span class="kw">qplot</span>(U3[, <span class="dv">1</span>], U3[, <span class="dv">2</span>]) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>()</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-7-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(magrittr)
<span class="kw">apply</span>(U3, <span class="dv">2</span>, <span class="cf">function</span>(x) <span class="kw">which</span>( <span class="kw">abs</span>(x <span class="op">-</span><span class="st"> </span><span class="kw">mean</span>(x)) <span class="op">&gt;</span><span class="st"> </span>(<span class="dv">6</span> <span class="op">*</span><span class="st"> </span><span class="kw">sd</span>(x)) )) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">Reduce</span>(union, .)</code></pre></div>
<pre><code>## [1] 1</code></pre>
<p>Now, the first sample is considered as an outlier by this criterion.</p>
</div>
<div id="a-more-robust-variation" class="section level3">
<h3>A more robust variation</h3>
<p>Note that you might want to use <code>median()</code> instead of <code>mean()</code> and <code>mad()</code> instead of <code>sd()</code> because they are more robust estimators. This becomes</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">ind.out &lt;-<span class="st"> </span><span class="kw">apply</span>(U3, <span class="dv">2</span>, <span class="cf">function</span>(x) <span class="kw">which</span>( (<span class="kw">abs</span>(x <span class="op">-</span><span class="st"> </span><span class="kw">median</span>(x)) <span class="op">/</span><span class="st"> </span><span class="kw">mad</span>(x)) <span class="op">&gt;</span><span class="st"> </span><span class="dv">6</span> )) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">Reduce</span>(union, .) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">print</span>()</code></pre></div>
<pre><code>## [1]   1 516</code></pre>
<p>We get a new outlier.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">col &lt;-<span class="st"> </span><span class="kw">rep</span>(<span class="st">&quot;black&quot;</span>, <span class="kw">nrow</span>(U3)); col[ind.out] &lt;-<span class="st"> &quot;red&quot;</span>
<span class="kw">qplot</span>(U3[, <span class="dv">1</span>], U3[, <span class="dv">3</span>], <span class="dt">color =</span> <span class="kw">I</span>(col), <span class="dt">size =</span> <span class="kw">I</span>(<span class="dv">2</span>)) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>()</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-9-1.png" width="80%" style="display: block; margin: auto;" /></p>
</div>
<div id="a-continuous-view-of-this-criterion" class="section level3">
<h3>A continuous view of this criterion</h3>
<p>This criterion flag an outlier if it is an outlier for at least one principal component (PC). This corresponds to using the <code>max()</code> (infinite) distance (in terms of number of standard deviations) from the mean.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">dist &lt;-<span class="st"> </span><span class="kw">apply</span>(U3, <span class="dv">2</span>, <span class="cf">function</span>(x) <span class="kw">abs</span>(x <span class="op">-</span><span class="st"> </span><span class="kw">median</span>(x)) <span class="op">/</span><span class="st"> </span><span class="kw">mad</span>(x)) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">apply</span>(<span class="dv">1</span>, max)
<span class="kw">qplot</span>(U3[, <span class="dv">1</span>], U3[, <span class="dv">3</span>], <span class="dt">color =</span> dist, <span class="dt">size =</span> <span class="kw">I</span>(<span class="dv">3</span>)) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>() <span class="op">+</span><span class="st"> </span>
<span class="st">  </span><span class="kw">scale_color_viridis_c</span>(<span class="dt">trans =</span> <span class="st">&quot;log&quot;</span>, <span class="dt">breaks =</span> <span class="kw">c</span>(<span class="dv">1</span>, <span class="dv">3</span>, <span class="dv">6</span>))</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-10-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">qplot</span>(<span class="dt">y =</span> <span class="kw">sort</span>(dist, <span class="dt">decreasing =</span> <span class="ot">TRUE</span>)) <span class="op">+</span>
<span class="st">  </span><span class="kw">geom_hline</span>(<span class="dt">yintercept =</span> <span class="dv">6</span>, <span class="dt">color =</span> <span class="st">&quot;red&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-11-1.png" width="70%" style="display: block; margin: auto;" /></p>
</div>
</div>
<div id="investigating-two-other-criteria-of-outlierness" class="section level2">
<h2>Investigating two other criteria of outlierness</h2>
<div id="robust-mahalanobis-distance" class="section level3">
<h3>Robust Mahalanobis distance</h3>
<p>Instead of using the infinite distance, Mahalanobis distance is a multivariate distance based on all variables (PCs here) at once. We use a robust version of this distance, which is implemented in packages {robust} and {robustbase} <span class="citation">(Gnanadesikan and Kettenring 1972, <span class="citation">Yohai and Zamar (1988)</span>, <span class="citation">Maronna and Zamar (2002)</span>, <span class="citation">Todorov, Filzmoser, and others (2009)</span>)</span> and that is reexported in {bigutilsr}.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">dist2 &lt;-<span class="st"> </span><span class="kw">covRob</span>(U3, <span class="dt">estim =</span> <span class="st">&quot;pairwiseGK&quot;</span>)<span class="op">$</span>dist
<span class="kw">qplot</span>(dist, <span class="kw">sqrt</span>(dist2))</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-12-1.png" width="70%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">cowplot<span class="op">::</span><span class="kw">plot_grid</span>(
  <span class="kw">qplot</span>(U3[, <span class="dv">1</span>], U3[, <span class="dv">2</span>], <span class="dt">color =</span> dist2, <span class="dt">size =</span> <span class="kw">I</span>(<span class="dv">2</span>)) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>() <span class="op">+</span><span class="st"> </span>
<span class="st">    </span><span class="kw">scale_color_viridis_c</span>(<span class="dt">trans =</span> <span class="st">&quot;log&quot;</span>, <span class="dt">breaks =</span> <span class="ot">NULL</span>),
  <span class="kw">qplot</span>(U3[, <span class="dv">3</span>], U3[, <span class="dv">7</span>], <span class="dt">color =</span> dist2, <span class="dt">size =</span> <span class="kw">I</span>(<span class="dv">2</span>)) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>() <span class="op">+</span><span class="st"> </span>
<span class="st">    </span><span class="kw">scale_color_viridis_c</span>(<span class="dt">trans =</span> <span class="st">&quot;log&quot;</span>, <span class="dt">breaks =</span> <span class="ot">NULL</span>),
  <span class="dt">rel_widths =</span> <span class="kw">c</span>(<span class="fl">0.7</span>, <span class="fl">0.4</span>), <span class="dt">scale =</span> <span class="fl">0.95</span>
)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-13-1.png" width="95%" style="display: block; margin: auto;" /></p>
<p>This new criterion provides similar results for this data. These robust Mahalanobis distances are approximately Chi-square distributed, which enables deriving p-values of outlierness.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">pval &lt;-<span class="st"> </span><span class="kw">pchisq</span>(dist2, <span class="dt">df =</span> <span class="dv">10</span>, <span class="dt">lower.tail =</span> <span class="ot">FALSE</span>)
<span class="kw">hist</span>(pval)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-14-1.png" width="70%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">is.out &lt;-<span class="st"> </span>(pval <span class="op">&lt;</span><span class="st"> </span>(<span class="fl">0.05</span> <span class="op">/</span><span class="st"> </span><span class="kw">length</span>(dist2)))  <span class="co"># Bonferroni correction</span>
<span class="kw">sum</span>(is.out)</code></pre></div>
<pre><code>## [1] 33</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">qplot</span>(U3[, <span class="dv">3</span>], U3[, <span class="dv">7</span>], <span class="dt">color =</span> is.out, <span class="dt">size =</span> <span class="kw">I</span>(<span class="dv">3</span>)) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>()</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-14-2.png" width="70%" style="display: block; margin: auto;" /></p>
</div>
<div id="local-outlier-factor-lof" class="section level3">
<h3>Local Outlier Factor (LOF)</h3>
<p>LOF statistic <span class="citation">(Breunig et al. 2000)</span> has been cited more than 4000 times. Instead of computing a distance from the center, it uses some local density of points. We make use of the fast K nearest neighbours implementation of R package {nabor} <span class="citation">(Elseberg et al. 2012)</span> to implement this statistic efficiently in {bigutilsr}.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">llof &lt;-<span class="st"> </span><span class="kw">LOF</span>(U3)  <span class="co"># log(LOF) by default</span>
<span class="kw">qplot</span>(dist2, llof)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-15-1.png" width="70%" style="display: block; margin: auto;" /></p>
<p>The fake outlier that we introduced is now clearly an outlier. The other points, not so much.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">cowplot<span class="op">::</span><span class="kw">plot_grid</span>(
  <span class="kw">qplot</span>(U3[, <span class="dv">1</span>], U3[, <span class="dv">2</span>], <span class="dt">color =</span> llof, <span class="dt">size =</span> <span class="kw">I</span>(<span class="dv">3</span>)) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>() <span class="op">+</span><span class="st"> </span>
<span class="st">    </span><span class="kw">scale_color_viridis_c</span>(<span class="dt">breaks =</span> <span class="ot">NULL</span>),
  <span class="kw">qplot</span>(U3[, <span class="dv">3</span>], U3[, <span class="dv">7</span>], <span class="dt">color =</span> llof, <span class="dt">size =</span> <span class="kw">I</span>(<span class="dv">3</span>)) <span class="op">+</span><span class="st"> </span><span class="kw">coord_equal</span>() <span class="op">+</span><span class="st"> </span>
<span class="st">    </span><span class="kw">scale_color_viridis_c</span>(<span class="dt">breaks =</span> <span class="ot">NULL</span>),
  <span class="dt">rel_widths =</span> <span class="kw">c</span>(<span class="fl">0.7</span>, <span class="fl">0.4</span>), <span class="dt">scale =</span> <span class="fl">0.95</span>
)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-16-1.png" width="95%" style="display: block; margin: auto;" /></p>
</div>
</div>
<div id="choosing-the-threshold-of-being-an-outlier" class="section level2">
<h2>Choosing the threshold of being an outlier</h2>
<p>Threshold of <code>6</code> for the first criterion presented here may appear arbitrary. If the data you have is normally distributed, each sample (for each PC) has a probability of <code>2 * pnorm(-6)</code> (2e-9) of being considered as an outlier by this criterion.</p>
<p>Accounting for multiple testing, <em>for 10K samples and 10 PCs</em>, there is a chance of <code>1 - (1 - 2 * pnorm(-6))^100e3</code> (2e-4) of detecting at least one outlier. If choosing <code>5</code> as threshold, there is 5.6% chance of detecting at least one outlier when PCs are normally distributed. If choosing <code>3</code> instead, this probability is 1.</p>
<div id="tukeys-rule" class="section level3">
<h3>Tukey’s rule</h3>
<p>Tukey’s rule <span class="citation">(Tukey 1977)</span> is a standard rule for detecting outliers. Here, we will apply it on the previously computed statistics. Note that we could use it directly on PCs, which is not much different from the robust version of the first criterion we introduced.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">x &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="dv">10000</span>)
(tukey_up  &lt;-<span class="st"> </span><span class="kw">quantile</span>(x, <span class="fl">0.75</span>) <span class="op">+</span><span class="st"> </span><span class="fl">1.5</span> <span class="op">*</span><span class="st"> </span><span class="kw">IQR</span>(x))</code></pre></div>
<pre><code>##     75% 
## 2.70692</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">(tukey_low &lt;-<span class="st"> </span><span class="kw">quantile</span>(x, <span class="fl">0.25</span>) <span class="op">-</span><span class="st"> </span><span class="fl">1.5</span> <span class="op">*</span><span class="st"> </span><span class="kw">IQR</span>(x))</code></pre></div>
<pre><code>##       25% 
## -2.725665</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">hist</span>(x); <span class="kw">abline</span>(<span class="dt">v =</span> <span class="kw">c</span>(tukey_low, tukey_up), <span class="dt">col =</span> <span class="st">&quot;red&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-17-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">mean</span>(x <span class="op">&lt;</span><span class="st"> </span>tukey_low <span class="op">|</span><span class="st"> </span>x <span class="op">&gt;</span><span class="st"> </span>tukey_up)</code></pre></div>
<pre><code>## [1] 0.0057</code></pre>
<p>where <code>IQR(x)</code> is equal to <code>quantile(x, 0.75) - quantile(x, 0.25)</code> (the InterQuartile Range).</p>
<p>However, there are two pitfalls when using Tukey’s rule:</p>
<ol style="list-style-type: decimal">
<li><p>Tukey’s rule assumes a normally distributed sample. When the data is skewed, it does not work that well.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">x &lt;-<span class="st"> </span><span class="kw">rchisq</span>(<span class="dv">10000</span>, <span class="dt">df =</span> <span class="dv">5</span>)
(tukey_up  &lt;-<span class="st"> </span><span class="kw">quantile</span>(x, <span class="fl">0.75</span>) <span class="op">+</span><span class="st"> </span><span class="fl">1.5</span> <span class="op">*</span><span class="st"> </span><span class="kw">IQR</span>(x))</code></pre></div>
<pre><code>##      75% 
## 12.42084</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">(tukey_low &lt;-<span class="st"> </span><span class="kw">quantile</span>(x, <span class="fl">0.25</span>) <span class="op">-</span><span class="st"> </span><span class="fl">1.5</span> <span class="op">*</span><span class="st"> </span><span class="kw">IQR</span>(x))</code></pre></div>
<pre><code>##       25% 
## -3.232256</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">hist</span>(x, <span class="st">&quot;FD&quot;</span>); <span class="kw">abline</span>(<span class="dt">v =</span> <span class="kw">c</span>(tukey_low, tukey_up), <span class="dt">col =</span> <span class="st">&quot;red&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-18-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">mean</span>(x <span class="op">&lt;</span><span class="st"> </span>tukey_low <span class="op">|</span><span class="st"> </span>x <span class="op">&gt;</span><span class="st"> </span>tukey_up)</code></pre></div>
<pre><code>## [1] 0.0294</code></pre>
<p>To solve the problem of skewness, the medcouple (mc) has been introduced <span class="citation">(Hubert and Vandervieren 2008)</span> and is implemented in <code>robustbase::adjboxStats()</code>.</p></li>
<li><p>Tukey’s rule uses a fixed coefficient (<code>1.5</code>) that does not account for multiple testing, which means that for large samples, you will almost always get some outliers if using <code>1.5</code>.</p></li>
</ol>
<p>To solve these two issues, we implemented <code>tukey_mc_up()</code> that accounts both for skewness and multiple testing by default.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">x &lt;-<span class="st"> </span><span class="kw">rchisq</span>(<span class="dv">10000</span>, <span class="dt">df =</span> <span class="dv">5</span>)
(tukey_up  &lt;-<span class="st"> </span><span class="kw">quantile</span>(x, <span class="fl">0.75</span>) <span class="op">+</span><span class="st"> </span><span class="fl">1.5</span> <span class="op">*</span><span class="st"> </span><span class="kw">IQR</span>(x))</code></pre></div>
<pre><code>##      75% 
## 12.48751</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">hist</span>(x, <span class="st">&quot;FD&quot;</span>); <span class="kw">abline</span>(<span class="dt">v =</span> tukey_up, <span class="dt">col =</span> <span class="st">&quot;red&quot;</span>)
<span class="kw">abline</span>(<span class="dt">v =</span> <span class="kw">print</span>(<span class="kw">tukey_mc_up</span>(x, <span class="dt">coef =</span> <span class="fl">1.5</span>)), <span class="dt">col =</span> <span class="st">&quot;blue&quot;</span>)</code></pre></div>
<pre><code>## [1] 16.74215</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">abline</span>(<span class="dt">v =</span> <span class="kw">print</span>(<span class="kw">tukey_mc_up</span>(x)), <span class="dt">col =</span> <span class="st">&quot;green&quot;</span>)  <span class="co"># accounts for multiple testing</span></code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-19-1.png" width="80%" style="display: block; margin: auto;" /></p>
<pre><code>## [1] 25.93299</code></pre>
<p>Applying this corrected Tukey’s rule to our statistics:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">tukey_mc_up</span>(dist)</code></pre></div>
<pre><code>## [1] 6.406337</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">qplot</span>(dist2, llof) <span class="op">+</span>
<span class="st">  </span><span class="kw">geom_vline</span>(<span class="dt">xintercept =</span> <span class="kw">tukey_mc_up</span>(dist2), <span class="dt">color =</span> <span class="st">&quot;red&quot;</span>) <span class="op">+</span>
<span class="st">  </span><span class="kw">geom_hline</span>(<span class="dt">yintercept =</span> <span class="kw">tukey_mc_up</span>(llof),  <span class="dt">color =</span> <span class="st">&quot;red&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-20-1.png" width="70%" style="display: block; margin: auto;" /></p>
</div>
<div id="histograms-gap" class="section level3">
<h3>Histogram’s gap</h3>
<p>This rule I come up with assumes that the “normal” data is somewhat grouped and the outliers have some gap (in the histogram, there is a bin with no value in it) with the rest of the data.</p>
<p>For example, for <code>dist</code>, there is a gap just before 6, and we can derive an algorithm to detect this:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">hist</span>(dist, <span class="dt">breaks =</span> nclass.scottRob)
<span class="kw">str</span>(<span class="kw">hist_out</span>(dist))</code></pre></div>
<pre><code>## List of 2
##  $ x  : num [1:515] 2.08 2.06 1.74 1.86 2.04 ...
##  $ lim: num [1:2] -Inf 5.75</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">abline</span>(<span class="dt">v =</span> <span class="kw">hist_out</span>(dist)<span class="op">$</span>lim[<span class="dv">2</span>], <span class="dt">col =</span> <span class="st">&quot;red&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-21-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">hist</span>(dist2, <span class="dt">breaks =</span> nclass.scottRob)
<span class="kw">abline</span>(<span class="dt">v =</span> <span class="kw">hist_out</span>(dist2)<span class="op">$</span>lim[<span class="dv">2</span>], <span class="dt">col =</span> <span class="st">&quot;red&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-22-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">hist</span>(llof, <span class="dt">breaks =</span> nclass.scottRob)
<span class="kw">abline</span>(<span class="dt">v =</span> <span class="kw">hist_out</span>(llof)<span class="op">$</span>lim[<span class="dv">2</span>], <span class="dt">col =</span> <span class="st">&quot;red&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-23-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>This criterion is convenient because it does not assume any distribution of the data, just that it is compact and that the outliers are not in the pack.</p>
<p>It could be used in other contexts, e.g. choosing the number of outlier principal components:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">eigval &lt;-<span class="st"> </span>pca<span class="op">$</span>sdev<span class="op">^</span><span class="dv">2</span>
<span class="kw">hist</span>(eigval, <span class="dt">breaks =</span> <span class="st">&quot;FD&quot;</span>)  <span class="co"># &quot;FD&quot; gives a bit more bins than scottRob</span>
<span class="kw">abline</span>(<span class="dt">v =</span> <span class="kw">hist_out</span>(eigval, <span class="dt">breaks =</span> <span class="st">&quot;FD&quot;</span>)<span class="op">$</span>lim[<span class="dv">2</span>], <span class="dt">col =</span> <span class="st">&quot;red&quot;</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-outlier-pca_files/figure-html/unnamed-chunk-24-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">sum</span>(eigval <span class="op">&gt;</span><span class="st"> </span><span class="kw">hist_out</span>(eigval, <span class="dt">breaks =</span> <span class="st">&quot;FD&quot;</span>)<span class="op">$</span>lim[<span class="dv">2</span>])</code></pre></div>
<pre><code>## [1] 3</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">pca_nspike</span>(eigval)  <span class="co"># directly implemented in {bigutilsr}</span></code></pre></div>
<pre><code>## [1] 3</code></pre>
<p>Note the possible use of bootstrap to make <code>hist_out()</code> and <code>pca_nspike()</code> more robust.</p>
</div>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>Outlier detection is not an easy task, especially if you want the criterion of outlierness to be robust to several factors such as sample size and distribution of the data. Moreover, there is always some threshold to choose to separate outliers from non-ouliers.</p>
<p>With one small example, we have seen several statistics to compute some degree of outlierness:</p>
<ol style="list-style-type: decimal">
<li>“6 standard deviations away from the mean” that somewhat assumes that PCs are normally distributed. Here, data is more a mixture of distributions (one for each cluster) than one normal distribution so that it might not work that well.</li>
<li>Mahalanobis distance that also assumes a (multivariate) normal distribution but that takes into account the correlation between PCs (that is not the identity because we use a robust estimation).</li>
<li>Local Outlier Factor (LOF) that does not assume any distribution and that finds points that are in empty areas (far from every other points) rather than points that are far from the center. One drawback is that this statistic has an hyper-parameter K (nearest neighbours); we combine three different values by default to make this statistic more robust to the choice of this parameter K.</li>
</ol>
<p>and several ways to decide the threshold of being an outlier according to those statistics:</p>
<ol style="list-style-type: decimal">
<li>Tukey’s rule, adjusting for skewness and multiple testing.</li>
<li>“Histogram’s gap” that finds a gap between outlier values and “normal” values based on a histogram.</li>
</ol>
<p>I have been investigating outlier detection in the past weeks. Any feedback and further input on this would be great.</p>
</div>
<div id="references" class="section level2 unnumbered">
<h2>References</h2>
<div id="refs" class="references">
<div id="ref-breunig2000lof">
<p>Breunig, Markus M, Hans-Peter Kriegel, Raymond T Ng, and Jörg Sander. 2000. “LOF: Identifying Density-Based Local Outliers.” In <em>ACM Sigmod Record</em>, 29:93–104. 2. ACM.</p>
</div>
<div id="ref-elseberg2012comparison">
<p>Elseberg, Jan, Stéphane Magnenat, Roland Siegwart, and Andreas Nüchter. 2012. “Comparison of Nearest-Neighbor-Search Strategies and Implementations for Efficient Shape Registration.” <em>Journal of Software Engineering for Robotics</em> 3 (1): 2–12.</p>
</div>
<div id="ref-gnanadesikan1972robust">
<p>Gnanadesikan, Ramanathan, and John R Kettenring. 1972. “Robust Estimates, Residuals, and Outlier Detection with Multiresponse Data.” <em>Biometrics</em>. JSTOR, 81–124.</p>
</div>
<div id="ref-hubert2008adjusted">
<p>Hubert, Mia, and Ellen Vandervieren. 2008. “An Adjusted Boxplot for Skewed Distributions.” <em>Computational Statistics &amp; Data Analysis</em> 52 (12). Elsevier: 5186–5201.</p>
</div>
<div id="ref-maronna2002robust">
<p>Maronna, Ricardo A, and Ruben H Zamar. 2002. “Robust Estimates of Location and Dispersion for High-Dimensional Datasets.” <em>Technometrics</em> 44 (4). Taylor &amp; Francis: 307–17.</p>
</div>
<div id="ref-todorov2009object">
<p>Todorov, Valentin, Peter Filzmoser, and others. 2009. “An Object-Oriented Framework for Robust Multivariate Analysis.” Citeseer.</p>
</div>
<div id="ref-tukey77">
<p>Tukey, John W. 1977. <em>Exploratory Data Analysis</em>. Addison-Wesley.</p>
</div>
<div id="ref-yohai1988high">
<p>Yohai, Victor J, and Ruben H Zamar. 1988. “High Breakdown-Point Estimates of Regression by Means of the Minimization of an Efficient Scale.” <em>Journal of the American Statistical Association</em> 83 (402). Taylor &amp; Francis: 406–13.</p>
</div>
</div>
</div>
</section>
