---
title: "One month as a procrastinator on Stack Overflow"

author: "Florian Privé"
date: "July 27, 2017"
layout: post
---

<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO_files/htmlwidgets-0.8/htmlwidgets.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO_files/jquery-1.12.4/jquery.min.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO_files/datatables-binding-0.2.12/datatables.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO_files/dt-core-1.10.12/js/jquery.dataTables.min.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO_files/crosstalk-1.0.1/js/crosstalk.min.js"></script>

<section class="main-content">
<p>Hello everyone, I’m 6103040 aka F. Privé. In this post, I will give some insights about answering questions on Stack Overflow (SO) for a month. One of the reason I’ve began frenetically answering questions on Stack Overflow was to procrastinate while finishing a scientific manuscript.</p>
<div id="my-activity-on-stack-overflow" class="section level2">
<h2>My activity on Stack Overflow</h2>
<p>We’ll use David Robinson’s package <strong>stackr</strong> to get data from Stack Overflow API.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="co"># devtools::install_github(&quot;dgrtwo/stackr&quot;)</span>
<span class="kw">suppressMessages</span>({
  <span class="kw">library</span>(stackr)
  <span class="kw">library</span>(tidyverse)
  <span class="kw">library</span>(lubridate)
})</code></pre></div>
<div id="evolution-my-so-reputation" class="section level3">
<h3>Evolution my SO reputation</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">myID &lt;-<span class="st"> &quot;6103040&quot;</span>

myRep &lt;-<span class="st"> </span><span class="kw">stack_users</span>(myID, <span class="st">&quot;reputation-history&quot;</span>, <span class="dt">num_pages =</span> <span class="dv">10</span>)

(p &lt;-<span class="st"> </span>myRep %&gt;%
<span class="st">    </span><span class="kw">arrange</span>(creation_date) %&gt;%
<span class="st">    </span><span class="kw">ggplot</span>(<span class="kw">aes</span>(creation_date, <span class="kw">cumsum</span>(reputation_change))) %&gt;%
<span class="st">    </span>bigstatsr:::<span class="kw">MY_THEME</span>() +
<span class="st">    </span><span class="kw">geom_point</span>() +
<span class="st">    </span><span class="kw">labs</span>(<span class="dt">x =</span> <span class="st">&quot;Date&quot;</span>, <span class="dt">y =</span> <span class="st">&quot;Reputation&quot;</span>, 
         <span class="dt">title =</span> <span class="st">&quot;Evolution of my SO reputation over time&quot;</span>))</code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO_files/figure-html/unnamed-chunk-2-1.png" width="80%" style="display: block; margin: auto;" /></p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">p +
<span class="st">  </span><span class="kw">xlim</span>(<span class="kw">as.POSIXct</span>(<span class="kw">c</span>(<span class="kw">today</span>() -<span class="st"> </span><span class="kw">months</span>(<span class="dv">1</span>), <span class="kw">today</span>()))) +
<span class="st">  </span><span class="kw">geom_smooth</span>(<span class="dt">method =</span> <span class="st">&quot;lm&quot;</span>) +
<span class="st">  </span><span class="kw">ggtitle</span>(<span class="st">&quot;Evolution of my SO reputation over the last month&quot;</span>)</code></pre></div>
<pre><code>## Warning: Removed 39 rows containing non-finite values (stat_smooth).</code></pre>
<pre><code>## Warning: Removed 39 rows containing missing values (geom_point).</code></pre>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/post-SO_files/figure-html/unnamed-chunk-2-2.png" width="80%" style="display: block; margin: auto;" /></p>
</div>
<div id="analyzing-my-answers" class="section level3">
<h3>Analyzing my answers</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">(myAnswers &lt;-<span class="st"> </span><span class="kw">stack_users</span>(myID, <span class="st">&quot;answers&quot;</span>, <span class="dt">num_pages =</span> <span class="dv">10</span>,
                          <span class="dt">fromdate =</span> <span class="kw">today</span>() -<span class="st"> </span><span class="kw">months</span>(<span class="dv">1</span>)) %&gt;%
<span class="st">    </span><span class="kw">select</span>(-<span class="kw">starts_with</span>(<span class="st">&quot;owner&quot;</span>)) %&gt;%
<span class="st">    </span><span class="kw">arrange</span>(<span class="kw">desc</span>(score)) %&gt;%
<span class="st">    </span><span class="kw">as_tibble</span>())</code></pre></div>
<pre><code>## # A tibble: 63 x 7
##    is_accepted score  last_activity_date       creation_date answer_id
##          &lt;lgl&gt; &lt;int&gt;              &lt;dttm&gt;              &lt;dttm&gt;     &lt;int&gt;
##  1       FALSE     9 2017-07-17 11:07:14 2017-07-16 22:21:05  45132967
##  2       FALSE     5 2017-07-25 09:27:02 2017-07-25 09:27:02  45296612
##  3       FALSE     5 2017-07-09 08:27:24 2017-07-09 08:27:24  44993632
##  4        TRUE     4 2017-06-30 18:57:23 2017-06-30 18:56:04  44851544
##  5       FALSE     3 2017-07-09 11:15:17 2017-07-09 11:15:17  44994826
##  6        TRUE     3 2017-07-02 10:27:29 2017-07-02 10:27:29  44868837
##  7        TRUE     2 2017-07-25 19:44:33 2017-07-25 19:44:33  45310305
##  8        TRUE     2 2017-07-25 15:41:12 2017-07-25 15:41:12  45305138
##  9        TRUE     2 2017-07-23 12:55:24 2017-07-23 12:55:24  45264278
## 10        TRUE     2 2017-07-21 20:50:42 2017-07-21 20:13:12  45244205
## # ... with 53 more rows, and 2 more variables: question_id &lt;int&gt;,
## #   last_edit_date &lt;dttm&gt;</code></pre>
<p>So it seems I’ve answered 63 questions over the past month. Interestingly, my answers with the greatest scores were not accepted. You can get a look at these using</p>
<pre><code>sapply(c(&quot;https://stackoverflow.com/questions/45045318&quot;,
         &quot;https://stackoverflow.com/questions/45295642&quot;,
         &quot;https://stackoverflow.com/questions/44993400&quot;), browseURL)</code></pre>
<p>The first one is just translating some R code in Rcpp. The two other ones are <strong>dplyr</strong> questions.</p>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r">myAnswers %&gt;%<span class="st"> </span>
<span class="st">  </span><span class="kw">group_by</span>(score) %&gt;%
<span class="st">  </span><span class="kw">summarise</span>(
    <span class="dt">N =</span> <span class="kw">n</span>(),
    <span class="dt">acceptance_ratio =</span> <span class="kw">mean</span>(is_accepted)
  )</code></pre></div>
<pre><code>## # A tibble: 8 x 3
##   score     N acceptance_ratio
##   &lt;int&gt; &lt;int&gt;            &lt;dbl&gt;
## 1    -2     1        0.0000000
## 2     0    32        0.3125000
## 3     1    14        0.4285714
## 4     2    10        0.7000000
## 5     3     2        0.5000000
## 6     4     1        1.0000000
## 7     5     2        0.0000000
## 8     9     1        0.0000000</code></pre>
<p>My acceptance rate is quite bad.</p>
</div>
<div id="tags-im-involved-in" class="section level3">
<h3>Tags I’m involved in</h3>
<div class="sourceCode"><pre class="sourceCode r"><code class="sourceCode r"><span class="kw">stack_users</span>(myID, <span class="st">&quot;tags&quot;</span>, <span class="dt">num_pages =</span> <span class="dv">10</span>) %&gt;%
<span class="st">  </span><span class="kw">select</span>(name, count) %&gt;%
<span class="st">  </span>DT::<span class="kw">datatable</span>() </code></pre></div>
<div id="htmlwidget-76018622540b4a2a7939" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-76018622540b4a2a7939">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79"],["r","dplyr","dataframe","r-bigmemory","rcpp","parallel-foreach","rmarkdown","matrix","data.table","foreach","doparallel","list","loops","leaflet","knitr","for-loop","devtools","ggplot2","eigen","c++","apply","assign","csv","plot","parallel-processing","rlang","r-leaflet","tidyverse","time","web-crawler","web-scraping","roxygen2","r-package","rparallel","sample","select","shiny","shinyapps","sorting","split","statistics","survival","svd","tibble","tidyeval","pdf","random","plotly","plyr","primes","purrr","quote","multithreading","optimization","package","pander","panel-data","curve","bigdata","correlation","cox-regression","cross-validation","eigenvector","ellipsis","expr","ff","algorithm","data-manipulation","glm","grouping","indices","integral","integrate","domc","function","latex","lubridate","machine-learning","math"],[79,10,6,5,5,4,4,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>name<\/th>\n      <th>count<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"crosstalkOptions":{"key":null,"group":null},"columnDefs":[{"className":"dt-right","targets":2},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false},"selection":{"mode":"multiple","selected":null,"target":"row"}},"evals":[],"jsHooks":[]}</script>
<p><br/></p>
<ul>
<li><p>I’m obviously answering only R questions</p></li>
<li><p>Questions about data frames or <strong>dplyr</strong> are quite easy so that I’ve answered several of them</p></li>
<li><p>I’m answering tags <em>r-bigmemory</em>, <em>rcpp</em>, <em>foreach</em>, <em>parallel-foreach</em> as I’m getting good at it because of the package I’ve developed (see <a href="https://privefl.github.io/blog/package-bigstatsr-statistics-with-matrices-on-disk-user-2017/">my previous post</a>).</p></li>
</ul>
</div>
</div>
<div id="some-insights-from-this-experience" class="section level2">
<h2>Some insights from this experience</h2>
<ul>
<li><p><strong>purrr</strong> is badly received as a proxy of base R functions such as <code>sapply</code> and <code>lapply</code> (<a href="https://stackoverflow.com/questions/45101045/why-use-purrrmap-instead-of-lapply" class="uri">https://stackoverflow.com/questions/45101045/why-use-purrrmap-instead-of-lapply</a>)</p></li>
<li><p>People tend to use <strong>dplyr</strong> where base R functions are well-suited:</p>
<ul>
<li><a href="https://stackoverflow.com/questions/45244063/using-dplyr-to-replace-a-vector-of-names-with-new-names" class="uri">https://stackoverflow.com/questions/45244063/using-dplyr-to-replace-a-vector-of-names-with-new-names</a></li>
<li><a href="https://stackoverflow.com/questions/45243363/dplyr-to-calculate-of-prevalence-of-a-variable-in-a-condition" class="uri">https://stackoverflow.com/questions/45243363/dplyr-to-calculate-of-prevalence-of-a-variable-in-a-condition</a></li>
<li><a href="https://stackoverflow.com/questions/44881723/replace-column-by-another-table" class="uri">https://stackoverflow.com/questions/44881723/replace-column-by-another-table</a></li>
<li><a href="https://stackoverflow.com/questions/44995997/create-a-new-variable-using-dplyrmutate-and-pasting-two-existing-variables-for" class="uri">https://stackoverflow.com/questions/44995997/create-a-new-variable-using-dplyrmutate-and-pasting-two-existing-variables-for</a></li>
<li><a href="https://stackoverflow.com/questions/45309455/mean-function-producing-same-result" class="uri">https://stackoverflow.com/questions/45309455/mean-function-producing-same-result</a></li>
</ul></li>
<li><p>To avoid basic issues, I find very important to know base R classes and their accessors well (you just need to read <a href="http://adv-r.had.co.nz/">Advanced R</a>)</p></li>
<li><p>The tidyverse solves lots of problems (you just need to read <a href="http://r4ds.had.co.nz/">R for Data Science</a>)</p></li>
<li><p>Guiding to a solution is much more fun than just giving it (<a href="https://stackoverflow.com/questions/45308904" class="uri">https://stackoverflow.com/questions/45308904</a>).</p></li>
</ul>
</div>
<div id="conclusion-and-bonuses" class="section level2">
<h2>Conclusion and bonuses</h2>
<p>I think it has been a good experience to answer questions on SO for a month.</p>
<p>I’m proud of <a href="https://stackoverflow.com/a/45302898/6103040">this algorithm written only with <strong>dplyr</strong></a> that automatically get you a combination of variables to form a <a href="https://en.wikipedia.org/wiki/Unique_key">unique key</a> of a dataset. Also, I wanted to make a blog post about good practices for parallelization in R. I’m not sure how to do it and which format to use, but, for now, you can get <a href="https://stackoverflow.com/a/45196081/6103040">some good practices in one of my answer</a>. Finally, if you miss the previous infinite printing of a tibble, you can get a workaround <a href="https://stackoverflow.com/a/44868837/6103040">there</a>.</p>
</div>
</section>
