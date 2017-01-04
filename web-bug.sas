%macro webScholar;
/*memlib选项是将data放在内存里，而不是放在D盘，可以提高读取速度，最后别忘记把dataset存盘*/
libname mywork "D:\" memlib;

/*create temple output*/
proc sql;
        create table mywork.results_web (titles char(500), citenumber char(500));
quit;

/*pageno is the page returned by google search*/
/*q=python, python is the key key word*/
%do pageno = 0 %to 20 %by 10;
        data _null_;
                length url $ 256;
                url = 'http://scholar.google.com/scholar?start=0&q=python&hl=en&as_sdt=0,5';
                url = prxchange("s/start=0/start=&pageno/", 1, url);
                call symput("url", url);
        run;

        /*recfm=n becasue the size limit of SAS String, input them in chunks*/
        filename web url "%superq(url)" recfm=n debug;

       /*$varying very funny format, see document*/
        data mywork.web;
                length webtext $ 256;
                infile web length=len;
                input webtext $varying256.len;
                textlength = len;
        run;

        data mywork.extracted;
                length s $ 32767; /* maximum length of sas string*/
                length r $ 500;
                length cite $500;
                retain s; /*每次data步，将字符累加到s中，用了retain，s不会重置成缺失值*/
                set mywork.web;
                s = cats(s, webtext);

                /*用正则表达式来匹配标题和文献引用次数*/
                /*其他编程语言的话可以找到很多package来做，sas这一点不太方便*/
                position = .;
                do until (position = 0);
                        patternID = prxparse('/<h3(\w|\W)*?<\/h3>(\w|\W)*?>Cite(d by )??\d*<\/a>/i');
                        call prxsubstr(patternID, s, position, length);
                        if position ^= 0 then do;
                                patternID = prxparse('/<h3(\w|\W)*?<\/h3>/i');
                                call prxsubstr(patternID, s, position, length);
                                r = substr(s, position, length);

                                /*把标题中的tag之类的奇怪字符去掉*/
                                r = prxchange('s/(<[^>]*?>)|(\[[^\]]*?\])|(&[^;]*?;s?)//', -1, r);
                                s = substrn(s, position + length);
                                
                                patternID = prxparse('/>Cite(d by )??\d*<\/a>/i');
                                call prxsubstr(patternID, s, position, length);
                                cite = substr(s, position, length);

                                /*把数字提取出来*/
                                cite = prxchange('s/(\D*)(\d*)(\D*)/$2/',1, cite);
                                s = substrn(s, position + length);
                                output;
                        end;
                end;                
                if length(s) > 29000 then s = substrn(s, 257);
        run;


       /*将结果存起来，最后的数据中会有两个变量，论文的标题和引用次数*/
       /*因为开头memlib选项，这个dataset并没有存到硬盘中*/
        proc sql;
                insert into mywork.results_web
                select r, cite from mywork.extracted;
        quit;

%end;

%mend webScholar;

%webScholar
