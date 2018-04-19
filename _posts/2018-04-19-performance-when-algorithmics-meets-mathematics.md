---
title: "Performance: when algorithmics meets mathematics"

author: "Florian Privé"
date: "April 19, 2018"
layout: post
---


<section class="main-content">
<p>In this post, I talk about performance through an efficient algorithm I developed for finding closest points on a map. This algorithm uses both concepts from mathematics and algorithmics.</p>
<div id="problem-to-solve" class="section level2">
<h2>Problem to solve</h2>
<p>This problem comes from a <a href="https://stackoverflow.com/q/49863185/6103040">recent question on StackOverflow</a>.</p>
<blockquote>
<p>I have two matrices, one is 200K rows long, the other is 20K. For each row (which is a point) in the first matrix, I am trying to find which row (also a point) in the second matrix is closest to the point in the first matrix. This is the first method that I tried on a sample dataset:</p>
</blockquote>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Test dataset: longitude and latitude</span>
pixels.latlon &lt;-<span class="st"> </span><span class="kw">cbind</span>(<span class="kw">runif</span>(<span class="dv">200000</span>, <span class="dt">min =</span> <span class="op">-</span><span class="dv">180</span>, <span class="dt">max =</span> <span class="op">-</span><span class="dv">120</span>),
                       <span class="kw">runif</span>(<span class="dv">200000</span>, <span class="dt">min =</span> <span class="dv">50</span>, <span class="dt">max =</span> <span class="dv">85</span>))
grwl.latlon &lt;-<span class="st"> </span><span class="kw">cbind</span>(<span class="kw">runif</span>(<span class="dv">20000</span>, <span class="dt">min =</span> <span class="op">-</span><span class="dv">180</span>, <span class="dt">max =</span> <span class="op">-</span><span class="dv">120</span>),
                     <span class="kw">runif</span>(<span class="dv">20000</span>, <span class="dt">min =</span> <span class="dv">50</span>, <span class="dt">max =</span> <span class="dv">85</span>))
<span class="co"># Calculate the distance matrix</span>
<span class="kw">library</span>(geosphere)
dist.matrix &lt;-<span class="st"> </span><span class="kw">distm</span>(pixels.latlon, grwl.latlon, <span class="dt">fun =</span> distHaversine)
<span class="co"># Pick out the indices of the minimum distance</span>
rnum &lt;-<span class="st"> </span><span class="kw">apply</span>(dist.matrix, <span class="dv">1</span>, which.min)</code></pre></div>
<p>At first, this problem was a memory problem because <code>dist.matrix</code> would take 30GB.</p>
<p>A simple solution to overcome this memory problem has been proposed:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(geosphere)
rnum &lt;-<span class="st"> </span><span class="kw">apply</span>(pixels.latlon, <span class="dv">1</span>, <span class="cf">function</span>(x) {
  dm &lt;-<span class="st"> </span><span class="kw">distm</span>(x, grwl.latlon, <span class="dt">fun =</span> distHaversine)
  <span class="kw">which.min</span>(dm)
})</code></pre></div>
<p>Yet, a second problem remains, this solution would take 30-40 min to run.</p>
</div>
<div id="first-idea-of-improvement" class="section level2">
<h2>First idea of improvement</h2>
<p>In the same spirit as with this <a href="https://adv-r.hadley.nz/profiling.html#t-test">case study in book <em>Advanced R</em></a>, let us see the source code of the <code>distHaversine</code> function and see if we can adapt it for our particular problem.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">library</span>(geosphere)
distHaversine</code></pre></div>
<pre><code>## function (p1, p2, r = 6378137) 
## {
##     toRad &lt;- pi/180
##     p1 &lt;- .pointsToMatrix(p1) * toRad
##     if (missing(p2)) {
##         p2 &lt;- p1[-1, ]
##         p1 &lt;- p1[-nrow(p1), ]
##     }
##     else {
##         p2 &lt;- .pointsToMatrix(p2) * toRad
##     }
##     p = cbind(p1[, 1], p1[, 2], p2[, 1], p2[, 2], as.vector(r))
##     dLat &lt;- p[, 4] - p[, 2]
##     dLon &lt;- p[, 3] - p[, 1]
##     a &lt;- sin(dLat/2) * sin(dLat/2) + cos(p[, 2]) * cos(p[, 4]) * 
##         sin(dLon/2) * sin(dLon/2)
##     a &lt;- pmin(a, 1)
##     dist &lt;- 2 * atan2(sqrt(a), sqrt(1 - a)) * p[, 5]
##     return(as.vector(dist))
## }
## &lt;bytecode: 0x71c0490&gt;
## &lt;environment: namespace:geosphere&gt;</code></pre>
<p>So, what this code does:</p>
<ol style="list-style-type: decimal">
<li><p><code>.pointsToMatrix</code> verifies the format of the points to make sure that it is a two-column matrix with the longitude and latitude. Our data is already in this format, we don’t need this here.</p></li>
<li><p>it converts from degrees to radians by multiplying by <code>pi / 180</code>.</p></li>
<li><p>it computes some intermediate value <code>a</code>.</p></li>
<li><p>it computes the great-circle distance based on <code>a</code>.</p></li>
</ol>
<p>Knowing that latitude values are between -90° and 90°, you can show that the values of <code>a</code> are between 0 and 1. For these values, <code>dist(a)</code> is in an increasing function of <code>a</code>:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">curve</span>(<span class="kw">atan2</span>(<span class="kw">sqrt</span>(x), <span class="kw">sqrt</span>(<span class="dv">1</span> <span class="op">-</span><span class="st"> </span>x)), <span class="dt">from =</span> <span class="dv">0</span>, <span class="dt">to =</span> <span class="dv">1</span>)</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-closest-points_files/figure-html/unnamed-chunk-4-1.png" /><!-- --></p>
<p>So, in fact, to find the minimum distance, you just need to find the minimum <code>a</code>.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># p1 is just one point and p2 is a two-column matrix of points</span>
haversine2 &lt;-<span class="st"> </span><span class="cf">function</span>(p1, p2) {
  
  toRad &lt;-<span class="st"> </span>pi <span class="op">/</span><span class="st"> </span><span class="dv">180</span>
  p1 &lt;-<span class="st"> </span>p1 <span class="op">*</span><span class="st"> </span>toRad
  p2 &lt;-<span class="st"> </span>p2 <span class="op">*</span><span class="st"> </span>toRad

  dLat &lt;-<span class="st"> </span>p2[, <span class="dv">2</span>] <span class="op">-</span><span class="st"> </span>p1[<span class="dv">2</span>]
  dLon &lt;-<span class="st"> </span>p2[, <span class="dv">1</span>] <span class="op">-</span><span class="st"> </span>p1[<span class="dv">1</span>]
  <span class="kw">sin</span>(dLat <span class="op">/</span><span class="st"> </span><span class="dv">2</span>)<span class="op">^</span><span class="dv">2</span> <span class="op">+</span><span class="st"> </span><span class="kw">cos</span>(p1[<span class="dv">2</span>]) <span class="op">*</span><span class="st"> </span><span class="kw">cos</span>(p2[, <span class="dv">2</span>]) <span class="op">*</span><span class="st"> </span><span class="kw">sin</span>(dLon <span class="op">/</span><span class="st"> </span><span class="dv">2</span>)<span class="op">^</span><span class="dv">2</span>
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># Test dataset (use smaller size for now)</span>
N &lt;-<span class="st"> </span><span class="dv">200</span>
pixels.latlon &lt;-<span class="st"> </span><span class="kw">cbind</span>(<span class="kw">runif</span>(N, <span class="dt">min =</span> <span class="op">-</span><span class="dv">180</span>, <span class="dt">max =</span> <span class="op">-</span><span class="dv">120</span>),
                       <span class="kw">runif</span>(N, <span class="dt">min =</span> <span class="dv">50</span>, <span class="dt">max =</span> <span class="dv">85</span>))
grwl.latlon &lt;-<span class="st"> </span><span class="kw">cbind</span>(<span class="kw">runif</span>(<span class="dv">20000</span>, <span class="dt">min =</span> <span class="op">-</span><span class="dv">180</span>, <span class="dt">max =</span> <span class="op">-</span><span class="dv">120</span>),
                     <span class="kw">runif</span>(<span class="dv">20000</span>, <span class="dt">min =</span> <span class="dv">50</span>, <span class="dt">max =</span> <span class="dv">85</span>))

<span class="kw">system.time</span>({
  rnum &lt;-<span class="st"> </span><span class="kw">apply</span>(pixels.latlon, <span class="dv">1</span>, <span class="cf">function</span>(x) {
    dm &lt;-<span class="st"> </span><span class="kw">distm</span>(x, grwl.latlon, <span class="dt">fun =</span> distHaversine)
    <span class="kw">which.min</span>(dm)
  })
})</code></pre></div>
<pre><code>##    user  system elapsed 
##   1.852   0.559   2.408</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>({
  rnum2 &lt;-<span class="st"> </span><span class="kw">apply</span>(pixels.latlon, <span class="dv">1</span>, <span class="cf">function</span>(x) {
    a &lt;-<span class="st"> </span><span class="kw">haversine2</span>(x, grwl.latlon)
    <span class="kw">which.min</span>(a)
  })
})</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.380   0.001   0.383</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">all.equal</span>(rnum2, rnum)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<p>So, here we get a solution that is 4-5 times as fast because we restricted the source code to our special use case. Still, this is not fast enough in my opinion.</p>
</div>
<div id="second-idea-of-improvement" class="section level2">
<h2>Second idea of improvement</h2>
<p>Do you really have to compute distances between all points? For example, if two points are on very different latitudes, does it mean that they are very far from each other?</p>
<p>In <code>a &lt;- sin(dLat / 2)^2 + cos(p1[2]) * cos(p2[, 2]) * sin(dLon / 2)^2</code>, you have a sum of two positive terms. You can deduce that <code>a</code> is always superior to <code>sin(dLat / 2)^2</code>, which is equivalent to <code>2 * asin(sqrt(a))</code> is always superior to <code>dLat</code>.</p>
<p>In other terms, for a given point in your matrix, if you have already computed one <code>a0</code> corresponding to one point in the second matrix, a new point could have its <code>a</code> inferior to <code>a0</code> only if <code>dLat</code> is inferior to <code>2 * asin(sqrt(a0))</code>.</p>
<p><strong>So, using a sorted list of all latitudes and with good starting values for <code>a0</code>, you can quickly discard lots of points as being the closest one, just by considering their latitudes.</strong> Implementing this idea in R(cpp):</p>
<div class="sourceCode"><pre class="sourceCode cpp"><code class="sourceCode cpp"><span class="pp">#include </span><span class="im">&lt;Rcpp.h&gt;</span>
<span class="kw">using</span> <span class="kw">namespace</span> Rcpp;

<span class="dt">double</span> compute_a(<span class="dt">double</span> lat1, <span class="dt">double</span> long1, <span class="dt">double</span> lat2, <span class="dt">double</span> long2) {

  <span class="dt">double</span> sin_dLat = ::sin((lat2 - lat1) / <span class="dv">2</span>);
  <span class="dt">double</span> sin_dLon = ::sin((long2 - long1) / <span class="dv">2</span>);

  <span class="cf">return</span> sin_dLat * sin_dLat + ::cos(lat1) * ::cos(lat2) * sin_dLon * sin_dLon;
}

<span class="dt">int</span> find_min(<span class="dt">double</span> lat1, <span class="dt">double</span> long1,
             <span class="at">const</span> NumericVector&amp; lat2,
             <span class="at">const</span> NumericVector&amp; long2,
             <span class="dt">int</span> current0) {

  <span class="dt">int</span> m = lat2.size();
  <span class="dt">double</span> lat_k, lat_min, lat_max, a, a0;
  <span class="dt">int</span> k, current = current0;

  a0 = compute_a(lat1, long1, lat2[current], long2[current]);
  <span class="co">// Search before current0</span>
  lat_min = lat1 - <span class="dv">2</span> * ::asin(::sqrt(a0));
  <span class="cf">for</span> (k = current0 - <span class="dv">1</span>; k &gt;= <span class="dv">0</span>; k--) {
    lat_k = lat2[k];
    <span class="cf">if</span> (lat_k &gt; lat_min) {
      a = compute_a(lat1, long1, lat_k, long2[k]);
      <span class="cf">if</span> (a &lt; a0) {
        a0 = a;
        current = k;
        lat_min = lat1 - <span class="dv">2</span> * ::asin(::sqrt(a0));
      }
    } <span class="cf">else</span> {
      <span class="co">// No need to search further</span>
      <span class="cf">break</span>;
    }
  }
  <span class="co">// Search after current0</span>
  lat_max = lat1 + <span class="dv">2</span> * ::asin(::sqrt(a0));
  <span class="cf">for</span> (k = current0 + <span class="dv">1</span>; k &lt; m; k++) {
    lat_k = lat2[k];
    <span class="cf">if</span> (lat_k &lt; lat_max) {
      a = compute_a(lat1, long1, lat_k, long2[k]);
      <span class="cf">if</span> (a &lt; a0) {
        a0 = a;
        current = k;
        lat_max = lat1 + <span class="dv">2</span> * ::asin(::sqrt(a0));
      }
    } <span class="cf">else</span> {
      <span class="co">// No need to search further</span>
      <span class="cf">break</span>;
    }
  }

  <span class="cf">return</span> current;
} 

<span class="co">// [[Rcpp::export]]</span>
IntegerVector find_closest_point(<span class="at">const</span> NumericVector&amp; lat1,
                                 <span class="at">const</span> NumericVector&amp; long1,
                                 <span class="at">const</span> NumericVector&amp; lat2,
                                 <span class="at">const</span> NumericVector&amp; long2) {

  <span class="dt">int</span> n = lat1.size();
  IntegerVector res(n);

  <span class="dt">int</span> current = <span class="dv">0</span>;
  <span class="cf">for</span> (<span class="dt">int</span> i = <span class="dv">0</span>; i &lt; n; i++) {
    res[i] = current = find_min(lat1[i], long1[i], lat2, long2, current);
  }

  <span class="cf">return</span> res; <span class="co">// need +1</span>
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">find_closest &lt;-<span class="st"> </span><span class="cf">function</span>(lat1, long1, lat2, long2) {

  toRad &lt;-<span class="st"> </span>pi <span class="op">/</span><span class="st"> </span><span class="dv">180</span>
  lat1  &lt;-<span class="st"> </span>lat1  <span class="op">*</span><span class="st"> </span>toRad
  long1 &lt;-<span class="st"> </span>long1 <span class="op">*</span><span class="st"> </span>toRad
  lat2  &lt;-<span class="st"> </span>lat2  <span class="op">*</span><span class="st"> </span>toRad
  long2 &lt;-<span class="st"> </span>long2 <span class="op">*</span><span class="st"> </span>toRad

  ord1  &lt;-<span class="st"> </span><span class="kw">order</span>(lat1)
  rank1 &lt;-<span class="st"> </span><span class="kw">match</span>(<span class="kw">seq_along</span>(lat1), ord1)
  ord2  &lt;-<span class="st"> </span><span class="kw">order</span>(lat2)

  ind &lt;-<span class="st"> </span><span class="kw">find_closest_point</span>(lat1[ord1], long1[ord1], lat2[ord2], long2[ord2])

  ord2[ind <span class="op">+</span><span class="st"> </span><span class="dv">1</span>][rank1]
}</code></pre></div>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">system.time</span>(
  rnum3 &lt;-<span class="st"> </span><span class="kw">find_closest</span>(pixels.latlon[, <span class="dv">2</span>], pixels.latlon[, <span class="dv">1</span>], 
                        grwl.latlon[, <span class="dv">2</span>], grwl.latlon[, <span class="dv">1</span>])
)</code></pre></div>
<pre><code>##    user  system elapsed 
##   0.007   0.000   0.007</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">all.equal</span>(rnum3, rnum)</code></pre></div>
<pre><code>## [1] TRUE</code></pre>
<p>This is so much faster, because for one point in the first matrix, you just check only a small subset of the points in the second matrix. This solution takes 0.5 sec for <code>N = 2e4</code> and 4.2 sec for <code>N = 2e5</code>.</p>
<p><strong>4 seconds instead of 30-40 min!</strong></p>
<p>Mission accomplished.</p>
</div>
<div id="conclusion" class="section level2">
<h2>Conclusion</h2>
<p>Knowing some maths and some algorithmics can be useful if you are interested in performance.</p>
</div>
</section>
