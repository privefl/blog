---
title: "One year as a subscriber to Stack Overflow"

author: "Florian Privé"
date: "July 2, 2018"
layout: post
---

<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO-year_files/htmlwidgets-1.2/htmlwidgets.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO-year_files/jquery-1.12.4/jquery.min.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO-year_files/datatables-binding-0.4/datatables.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO-year_files/dt-core-1.10.16/js/jquery.dataTables.min.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO-year_files/crosstalk-1.0.0/js/crosstalk.min.js"></script>

<section class="main-content">
<p>In this post, I follow up on a <a href="https://privefl.github.io/blog/one-month-as-a-procrastinator-on-stack-overflow/">previous post</a> describing how last year in July, I spent one month mostly procrastinating on Stack Overflow (SO). We’re already in July so it’s time to get back to one year of activity on Stack Overflow.</p>
<p>Am I still as much active as before? <strong>What is my strategy for answering questions on SO?</strong></p>
<div id="my-activity-on-stack-overflow" class="section level2">
<h2>My activity on Stack Overflow</h2>
<p>Again, we’ll use David Robinson’s package {stackr} to get data from Stack Overflow API in R.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># devtools::install_github(&quot;dgrtwo/stackr&quot;)</span>
<span class="kw">suppressMessages</span>({
  <span class="kw">library</span>(stackr)
  <span class="kw">library</span>(tidyverse)
  <span class="kw">library</span>(lubridate)
})</code></pre></div>
<div id="evolution-of-my-so-reputation" class="section level3">
<h3>Evolution of my SO reputation</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">myID &lt;-<span class="st"> &quot;6103040&quot;</span>

myRep &lt;-<span class="st"> </span><span class="kw">stack_users</span>(myID, <span class="st">&quot;reputation-history&quot;</span>, <span class="dt">num_pages =</span> <span class="dv">40</span>,
                     <span class="dt">fromdate =</span> <span class="kw">today</span>() <span class="op">-</span><span class="st"> </span><span class="kw">years</span>(<span class="dv">1</span>))

myRep <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">arrange</span>(creation_date) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">ggplot</span>(<span class="kw">aes</span>(creation_date, <span class="kw">cumsum</span>(reputation_change))) <span class="op">+</span>
<span class="st">  </span><span class="kw">geom_point</span>() <span class="op">+</span>
<span class="st">  </span><span class="kw">labs</span>(<span class="dt">x =</span> <span class="st">&quot;Date&quot;</span>, <span class="dt">y =</span> <span class="st">&quot;Reputation (squared transformed)&quot;</span>) <span class="op">+</span>
<span class="st">  </span><span class="kw">ggtitle</span>(<span class="st">&quot;Evolution of my SO reputation over the last year&quot;</span>) <span class="op">+</span><span class="st"> </span>
<span class="st">  </span>bigstatsr<span class="op">::</span><span class="kw">theme_bigstatsr</span>()</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO-year_files/figure-html/unnamed-chunk-2-1.png" width="80%" style="display: block; margin: auto;" /></p>
<p>So, it seems that my activity is slowing gently (my reputation is almost proportional to the square root of time). Yet, it is still increasing steadily; so what is my strategy for answering questions on SO?</p>
</div>
<div id="analyzing-my-answers" class="section level3">
<h3>Analyzing my answers</h3>
<p>You’ll have to wait for the answer to what is my strategy for answering questions on SO. For a hint, let’s analyze my answers and tags I’m involved in.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">myAnswers &lt;-<span class="st"> </span><span class="kw">stack_users</span>(myID, <span class="st">&quot;answers&quot;</span>, <span class="dt">num_pages =</span> <span class="dv">30</span>,
                         <span class="dt">fromdate =</span> <span class="kw">today</span>() <span class="op">-</span><span class="st"> </span><span class="kw">years</span>(<span class="dv">1</span>))</code></pre></div>
<p>I’ve answered 228 questions over the past year.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">myAnswers <span class="op">%&gt;%</span><span class="st"> </span>
<span class="st">  </span><span class="kw">group_by</span>(score) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">summarise</span>(
    <span class="dt">N =</span> <span class="kw">n</span>(),
    <span class="dt">acceptance_ratio =</span> <span class="kw">mean</span>(is_accepted)
  )</code></pre></div>
<pre><code>## # A tibble: 10 x 3
##    score     N acceptance_ratio
##    &lt;int&gt; &lt;int&gt;            &lt;dbl&gt;
##  1    -1     4            0.250
##  2     0    78            0.346
##  3     1    76            0.447
##  4     2    44            0.545
##  5     3     9            0.444
##  6     4     6            0.667
##  7     5     6            0.833
##  8     6     2            1.00 
##  9     7     1            1.00 
## 10     9     2            0.500</code></pre>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">mean</span>(myAnswers<span class="op">$</span>score)</code></pre></div>
<pre><code>## [1] 1.219298</code></pre>
<p>It seems that these days, it is harder to get answers that are highly upvoted.</p>
</div>
<div id="tags-im-involved-in" class="section level3">
<h3>Tags I’m involved in</h3>
<p>If we don’t count my first month of activity:</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">stack_users</span>(myID, <span class="st">&quot;tags&quot;</span>, <span class="dt">num_pages =</span> <span class="dv">40</span>,
            <span class="dt">fromdate =</span> <span class="kw">today</span>() <span class="op">-</span><span class="st"> </span><span class="kw">months</span>(<span class="dv">11</span>)) <span class="op">%&gt;%</span>
<span class="st">  </span><span class="kw">select</span>(name, count) <span class="op">%&gt;%</span>
<span class="st">  </span>DT<span class="op">::</span><span class="kw">datatable</span>() </code></pre></div>
<div id="htmlwidget-46770ac9182c607c69d5" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-46770ac9182c607c69d5">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105","106","107","108","109","110","111","112","113","114","115","116","117","118","119","120","121","122","123","124","125","126","127","128","129","130","131","132","133","134","135","136","137","138","139","140","141","142","143","144","145","146","147","148","149","150","151","152","153","154","155"],["r","performance","rcpp","parallel-processing","foreach","r-bigmemory","vectorization","for-loop","matrix","doparallel","dataframe","optimization","function","dplyr","loops","apply","c++","ggplot2","lapply","combinations","parallel-foreach","r6","random","r-package","tidyverse","tree","travis-ci","while-loop","vector","r-markdown","roxygen2","tibble","parallel.foreach","plot","data.table","bigdata","armadillo","large-data","nnet","list","nse","max","downcasting","if-statement","image","int","ls","macos","magrittr","math","mathematical-optimization","ggtree","git","glmulti","global-variables","graph-algorithm","great-circle","gsl","html","htmlwidget","mclapply","mcmc","memory","moving-average","multicore","multidimensional-array","multidplyr","multinomial","multithreading","na","names","nested","nested-loops","netcdf","nodes","non-linear-regression","linux","matrix-multiplication","arrays","attributes","awk","aggregate","algorithm","animation","ape-phylo","boolean","boolean-logic","boost-variant","arguments","eigen","embed","extract","ff","finance","floating-point","folders","forcats","genome","geosphere","dbplyr","debugging","devtools","digits","dompi","plyr","position","probability-density","processing-efficiency","purrr","python","queue","package","raster","rparallel","rstudio","sample","sampling","sapply","scoping","sed","sentiment-analysis","seq","session","set-difference","shared-memory","snow","snowfall","solver","statistical-test","statistics","stochastic","stochastic-process","string","summarization","svd","system2","tapply","templates","text-analysis","roc","permutation","pkgdown","rds","recursion","ref","reference-class","regex","reshape","rlang","windows","xts","user-interface","vignette","warnings","which"],[187,36,34,33,19,14,12,11,11,10,8,8,7,7,7,6,6,5,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>name<\/th>\n      <th>count<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":2},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>
<p><br/></p>
<ul>
<li><p>I’m obviously answering only R questions</p></li>
<li><p>The tags I’m mostly answering questions from are “performance”, “rcpp”, “parallel-processing”, “foreach”, “r-bigmemory” and “vectorization”.</p></li>
</ul>
</div>
<div id="performance" class="section level3">
<h3>Performance</h3>
<p>As you can see, all these tags are about performance of code. I really enjoy performance problems (get the same result but much faster).</p>
<p>I can spend hours on a question about performance and am sometimes rewarded with a solution that is 2-3 order of magnitude faster (see e.g. <a href="https://privefl.github.io/blog/performance-when-algorithmics-meets-mathematics/">this other post</a>).</p>
<p>I hope I could share my knowledge about performance through a tutorial in Toulouse next year.</p>
</div>
</div>
<div id="conclusion-and-answer" class="section level2">
<h2>Conclusion and answer</h2>
<p>So, the question was “What is my strategy for answering questions on SO?”. And the answer is.. in the title: I am a subscriber.</p>
<p>I subscribe to tags on Stack Overflow. It has many benefits:</p>
<ul>
<li><p>you don’t have to <a href="https://meta.stackexchange.com/questions/9731/fastest-gun-in-the-west-problem">rush to answer</a> because questions you receive by mail are 30min-old (unanswered?) ones, so the probability that someone will answer at the same time as you is low.</p></li>
<li><p>you can focus and what you’re good at, what you’re interested in, or just what you want to learn. For example, I subscribed to the very new tag “r-future” (for the R package {future}) because I’m interested in this package, even if I don’t know how to use it yet. I had the chance to meet with its author, Henrik Bengtsson, at eRum2018 and he actually already knew me through parallel questions on SO :D.</p></li>
</ul>
<p>However, some tags (like “performance” or “foreach”) are relevant to many programming languages so that you would be flooded with irrelevant questions if subscribing directly to these tags. A simple solution to this problem is to subscribe to a feed of a combination of tags, like <a href="https://stackoverflow.com/feeds/tag?tagnames=r+and+foreach&amp;sort=newest" class="uri">https://stackoverflow.com/feeds/tag?tagnames=r+and+foreach&amp;sort=newest</a>. I use <a href="https://blogtrottr.com/">this website</a> to subscribe to feeds.</p>
<p>I will continue answering questions on SO, so see you there!</p>
<hr />
<p>PS: I’m not 100% sure you would get only unanswered questions with this technique.</p>
</div>
</section>
