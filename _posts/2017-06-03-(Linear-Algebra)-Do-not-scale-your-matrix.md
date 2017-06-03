---
title: (Linear Algebra) Do not scale your matrix
subtitle: Application to Principal Component Analysis
author: Florian Privé
date: June 3, 2017
layout: post
---


<section class="main-content">
<p>In this post, I will show you that you generally don’t need to explicitly scale a matrix. Maybe you wanted to know more about WHY matrices should be scaled when doing linear algebra. I will remind about that in the beginning but the rest will focus on HOW to not explicitly scale matrices. We will apply our findings to the computation of Principal Component Analysis (PCA) and then Pearson correlation at the end.</p>
<div id="why-scaling-matrices" class="section level2">
<h2>WHY scaling matrices?</h2>
<p>Generally, if you don’t center columns of a matrix before PCA, you end up with the loadings of PC1 being the column means, which is not of must interest.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">n &lt;-<span class="st"> </span><span class="dv">100</span>; m &lt;-<span class="st"> </span><span class="dv">10</span>
a &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dv">0</span>, n, m); a[] &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">length</span>(a))
a &lt;-<span class="st"> </span><span class="kw">sweep</span>(a, <span class="dv">2</span>, <span class="dv">1</span>:m, <span class="st">&#39;+&#39;</span>)
<span class="kw">colMeans</span>(a)</code></pre></div>
<pre><code>##  [1]  0.9969826  1.9922219  3.0894905  3.9680835  4.9433477  6.0007352
##  [7]  6.9524794  8.0898546  8.9506657 10.0354630</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">pca &lt;-<span class="st"> </span><span class="kw">prcomp</span>(a, <span class="dt">center =</span> <span class="ot">FALSE</span>)
<span class="kw">cor</span>(pca$rotation[, <span class="dv">1</span>], <span class="kw">colMeans</span>(a))</code></pre></div>
<pre><code>## [1] 0.9999991</code></pre>
<p>Now, say you have centered column or your matrix, do you also need to scale them? That is to say, do they need to have the same norm or standard deviation?</p>
<p>PCA consists in finding an orthogonal basis that maximizes the variation in the data you analyze. So, if there is a column with much more variation than the others, it will probably end up being PC1, which is not of must interest.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">n &lt;-<span class="st"> </span><span class="dv">100</span>; m &lt;-<span class="st"> </span><span class="dv">10</span>
a &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dv">0</span>, n, m); a[] &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">length</span>(a))
a[, <span class="dv">1</span>] &lt;-<span class="st"> </span><span class="dv">100</span> *<span class="st"> </span>a[, <span class="dv">1</span>]
<span class="kw">apply</span>(a, <span class="dv">2</span>, sd)</code></pre></div>
<pre><code>##  [1] 90.8562836  0.8949268  0.9514208  1.0437561  0.9995103  1.0475651
##  [7]  0.9531466  0.9651383  0.9804789  0.9605121</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">pca &lt;-<span class="st"> </span><span class="kw">prcomp</span>(a, <span class="dt">center =</span> <span class="ot">TRUE</span>)
pca$rotation[, <span class="dv">1</span>]</code></pre></div>
<pre><code>##  [1]  9.999939e-01  6.982439e-04 -5.037773e-04 -9.553513e-05  8.937869e-04
##  [6] -1.893732e-03 -3.053232e-04  1.811950e-03 -1.658014e-03  9.937442e-04</code></pre>
<p>Hope I convinced you on WHY it is important to scale matrix columns before doing PCA. I will now show you <strong>HOW not to do it explictly</strong>.</p>
</div>
<div id="reimplementation-of-pca" class="section level2">
<h2>Reimplementation of PCA</h2>
<p>In this part, I will show you the basic code if you want to reimplement PCA yourself. It will serve as a basis to show you how to do linear algebra on a scaled matrix, without explicitly scaling the matrix.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># True one</span>
n &lt;-<span class="st"> </span><span class="dv">100</span>; m &lt;-<span class="st"> </span><span class="dv">10</span>
a &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dv">0</span>, n, m); a[] &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">length</span>(a))
pca &lt;-<span class="st"> </span><span class="kw">prcomp</span>(a, <span class="dt">center =</span> <span class="ot">TRUE</span>, <span class="dt">scale. =</span> <span class="ot">TRUE</span>)
<span class="co"># DIY</span>
a.scaled &lt;-<span class="st"> </span><span class="kw">scale</span>(a, <span class="dt">center =</span> <span class="ot">TRUE</span>, <span class="dt">scale =</span> <span class="ot">TRUE</span>)
K &lt;-<span class="st"> </span><span class="kw">crossprod</span>(a.scaled)
K.eigs &lt;-<span class="st"> </span><span class="kw">eigen</span>(K, <span class="dt">symmetric =</span> <span class="ot">TRUE</span>)
v &lt;-<span class="st"> </span>K.eigs$vectors
PCs &lt;-<span class="st"> </span>a.scaled %*%<span class="st"> </span>v
<span class="co"># Verif, recall that PCs can be opposites between runs</span>
<span class="kw">plot</span>(v, pca$rotation)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-scale-matrix_files/figure-html/unnamed-chunk-3-1.png" /><!-- --></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">all.equal</span>(<span class="kw">sqrt</span>(K.eigs$values), <span class="kw">sqrt</span>(n -<span class="st"> </span><span class="dv">1</span>) *<span class="st"> </span>pca$sdev)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">plot</span>(PCs, pca$x)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-scale-matrix_files/figure-html/unnamed-chunk-3-2.png" /><!-- --></p>
</div>
<div id="linear-algebra-behind-the-previous-implementation" class="section level2">
<h2>Linear algebra behind the previous implementation</h2>
<p>Suppose <span class="math inline">\(m &lt; n\)</span> (<span class="math inline">\(m\)</span> is the number of columns and <span class="math inline">\(n\)</span> is the number of rows). Let us denote <span class="math inline">\(\tilde{X}\)</span> the scaled matrix. A partial singular value decomposition of <span class="math inline">\(\tilde{X}\)</span> is <span class="math inline">\(\tilde{X} \approx U \Delta V^T\)</span> where <span class="math inline">\(U\)</span> is an <span class="math inline">\(n \times K\)</span> matrix such that <span class="math inline">\(U^T U = I_K\)</span>, <span class="math inline">\(\Delta\)</span> is a <span class="math inline">\(K \times K\)</span> diagonal matrix and <span class="math inline">\(V\)</span> is an <span class="math inline">\(m \times K\)</span> matrix such that <span class="math inline">\(V^T V = I_K\)</span>. Taking <span class="math inline">\(K = m\)</span>, you end up with <span class="math inline">\(\tilde{X} = U \Delta V^T\)</span>.</p>
<p><span class="math inline">\(U \Delta\)</span> are the scores (PCs) of the PCA and <span class="math inline">\(V\)</span> are the loadings (rotation coefficients). <span class="math inline">\(K = \tilde{X}^T \tilde{X} = (U \Delta V^T)^T \cdot U \Delta V^T = V \Delta U^T U \Delta V^T = V \Delta^2 V^T\)</span>. So, when doing the eigen decomposition of K, you get <span class="math inline">\(V\)</span> and <span class="math inline">\(\Delta^2\)</span> because <span class="math inline">\(K V = V \Delta^2\)</span>. For getting the scores, you then compute <span class="math inline">\(\tilde{X} V = U \Delta\)</span>.</p>
<p>These are exactly the steps implemented above.</p>
</div>
<div id="implicit-scaling-of-the-matrix" class="section level2">
<h2>Implicit scaling of the matrix</h2>
<p>Do you know the matrix formulation of column scaling? <span class="math inline">\(\tilde{X} = C_n X S\)</span> where <span class="math inline">\(C_n = I_n - \frac{1}{n} 1_n 1_n^T\)</span> is the <a href="https://en.wikipedia.org/wiki/Centering_matrix">centering matrix</a> and <span class="math inline">\(S\)</span> is an <span class="math inline">\(m \times m\)</span> diagonal matrix with the scaling coefficients (typically, <span class="math inline">\(S_{j,j} = 1 / \text{sd}_j\)</span>).</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Let&#39;s verify</span>
sds &lt;-<span class="st"> </span><span class="kw">apply</span>(a, <span class="dv">2</span>, sd)
a.scaled2 &lt;-<span class="st"> </span>(<span class="kw">diag</span>(n) -<span class="st"> </span><span class="kw">tcrossprod</span>(<span class="kw">rep</span>(<span class="dv">1</span>, n)) /<span class="st"> </span>n) %*%<span class="st"> </span>a %*%<span class="st"> </span><span class="kw">diag</span>(<span class="dv">1</span> /<span class="st"> </span>sds)
<span class="kw">all.equal</span>(a.scaled2, a.scaled, <span class="dt">check.attributes =</span> <span class="ot">FALSE</span>)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<p>In our previous implementation, we computed <span class="math inline">\(\tilde{X}^T \tilde{X}\)</span> and <span class="math inline">\(\tilde{X} V\)</span>. We are going to compute them again, without explicitly scaling the matrix.</p>
<div id="product" class="section level3">
<h3>Product</h3>
<p>Let us begin by something easy: <span class="math inline">\(\tilde{X} V = C_n X S V = C_n (X (S V))\)</span>. So, you can compute <span class="math inline">\(\tilde{X} V\)</span> without explicitly scaling <span class="math inline">\(X\)</span>. Let us verify:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">SV &lt;-<span class="st"> </span>v /<span class="st"> </span>sds
XSV &lt;-<span class="st"> </span>a %*%<span class="st"> </span>SV
CXSV &lt;-<span class="st"> </span><span class="kw">sweep</span>(XSV, <span class="dv">2</span>, <span class="kw">colMeans</span>(XSV), <span class="st">&#39;-&#39;</span>)
<span class="kw">all.equal</span>(CXSV, PCs)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
</div>
<div id="self-cross-product" class="section level3">
<h3>Self cross-product</h3>
<p>A little more tricky: <span class="math inline">\(\tilde{X}^T \tilde{X} = (C_n X S)^T \cdot C_n X S = S^T X^T C_n X S\)</span> (<span class="math inline">\(C_n^2 = C_n\)</span> is intuitive because centering an already centered matrix doesn’t change it).</p>
<p><span class="math inline">\(\tilde{X}^T \tilde{X} = S^T X^T (I_n - \frac{1}{n} 1_n 1_n^T) X S = S^T (X^T X - X^T (\frac{1}{n} 1_n 1_n^T) X) S = S^T (X^T X - \frac{1}{n} s_X * s_X^T) S\)</span> where <span class="math inline">\(s_X\)</span> is the vector of column sums of X.</p>
<p>Let us verify with a rough implementation:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">sx &lt;-<span class="st"> </span><span class="kw">colSums</span>(a)
K2 &lt;-<span class="st"> </span>(<span class="kw">crossprod</span>(a) -<span class="st"> </span><span class="kw">tcrossprod</span>(sx) /<span class="st"> </span>n) /<span class="st"> </span><span class="kw">tcrossprod</span>(sds)
<span class="kw">all.equal</span>(K, K2)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
</div>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>We have recalled some steps about the computation of Principal Component Analysis on a scaled matrix. We have seen how to compute the different steps of the implementation without having to explicitly scale the matrix. This “implicit” scaling can be quite useful if you manipulate very large matrices because you are not copying the matrix nor making useless computation. In my next post, I will present to you my new package that uses this trick to make a lightning partial SVD on very large matrices.</p>
</div>
<div id="appendix-application-to-pearson-correlation" class="section level2">
<h2>Appendix: application to Pearson correlation</h2>
<p>Pearson correlation is merely a self cross-product on a centered and normalized (columns with unit norm) matrix. Let us just implement that with our new trick.</p>
<div class="sourceCode"><pre class="sourceCode cpp"><code class="sourceCode cpp"><span class="ot">#include &lt;Rcpp.h&gt;</span>
<span class="kw">using</span> <span class="kw">namespace</span> Rcpp;

<span class="co">// [[Rcpp::export]]</span>
NumericMatrix&amp; correlize(NumericMatrix&amp; mat,
                         <span class="dt">const</span> NumericVector&amp; shift,
                         <span class="dt">const</span> NumericVector&amp; scale) {
  
  <span class="dt">int</span> n = mat.nrow();
  <span class="dt">int</span> i, j;
  
  <span class="kw">for</span> (j = <span class="dv">0</span>; j &lt; n; j++) {
    <span class="kw">for</span> (i = <span class="dv">0</span>; i &lt; n; i++) {
      <span class="co">// corresponds to &quot;- \frac{1}{n} s_X * s_X^T&quot;</span>
      mat(i, j) -= shift(i) * shift(j);
      <span class="co">// corresponds to &quot;S^T (...) S&quot;</span>
      mat(i, j) /= scale(i) * scale(j);
    }
  }
  
  <span class="kw">return</span> mat;
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">cor3 &lt;-<span class="st"> </span>function(mat) {
  sums &lt;-<span class="st"> </span><span class="kw">colSums</span>(mat) /<span class="st"> </span><span class="kw">sqrt</span>(<span class="kw">nrow</span>(mat))
  corr &lt;-<span class="st"> </span><span class="kw">crossprod</span>(mat)
  diags &lt;-<span class="st"> </span><span class="kw">sqrt</span>(<span class="kw">diag</span>(corr) -<span class="st"> </span>sums^<span class="dv">2</span>)
  <span class="kw">correlize</span>(corr, <span class="dt">shift =</span> sums, <span class="dt">scale =</span> diags)
}

a &lt;-<span class="st"> </span><span class="kw">matrix</span>(<span class="dv">0</span>, <span class="dv">1000</span>, <span class="dv">1000</span>); a[] &lt;-<span class="st"> </span><span class="kw">rnorm</span>(<span class="kw">length</span>(a))
<span class="kw">all.equal</span>(<span class="kw">cor3</span>(a), <span class="kw">cor</span>(a))</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(microbenchmark)
<span class="kw">microbenchmark</span>(
  <span class="kw">cor3</span>(a),
  <span class="kw">cor</span>(a),
  <span class="dt">times =</span> <span class="dv">20</span>
)</code></pre></div>
<pre><code>## Unit: milliseconds
##     expr       min        lq      mean    median        uq       max neval
##  cor3(a)  39.38138  39.67276  40.68596  40.09893  40.65623  46.46785    20
##   cor(a) 635.74350 637.33605 639.34810 638.09980 639.36110 651.61876    20</code></pre>
</div>
</section>
