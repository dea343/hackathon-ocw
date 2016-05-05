# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy
import time
import json
from selenium import webdriver
from infoq_article.items import InfoqArticleItem
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

def cleanse(alist):
    return alist[0].strip().encode('utf-8').replace('"', '“').replace('\n', '').replace('\t', '    ').replace('\\', '“') if alist else u''

class InfoqSpider(scrapy.Spider):
    name = 'infoq_article'
    allowed_domains = ["www.infoq.com"]
    start_urls = ["http://www.infoq.com/cn/articles"]

    def __init__(self):
        scrapy.Spider.__init__(self)

        profile = webdriver.FirefoxProfile()
        profile.set_preference("general.useragent.override","Mozilla/5.0 (Linux; Android 4.4; Nexus 5 Build/BuildID) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36")
        self.driver = webdriver.Firefox(profile)

    def __del__(self):
        self.driver.close()

    def getout(self):
        if len(self.out) == 0:
            inputfile = open('out.json','r')
            lines = inputfile.readlines()
            inputfile.close()
            for line in lines:
                self.out.append(json.loads(line))
        return self.out

    def downloaded(self, link):
        out = self.getout()
        for js in out:
            if js['link'] == link:
                return True
        return False

    def parse(self, response):

        self.driver.get('http://www.infoq.com/cn/articles')
        time.sleep(2)
        
        while True:

            hxs = scrapy.Selector(text = self.driver.page_source)
            for info in hxs.xpath('/html/body/div[1]/div/ul[2]/li'):
                item = InfoqArticleItem()
                link = cleanse(info.xpath('a[1]/@href').extract())
                link = 'http://www.infoq.com{0}'.format(link)
                if self.downloaded(link): return
                item['link'] = link
                yield item

            next = self.driver.find_element_by_xpath('/html/body/div[1]/div/ul[1]/li[2]/a')
            #print next.text
            time.sleep(2)

            try:
                next.click()

            except Exception as err:
                print(err)
                break






