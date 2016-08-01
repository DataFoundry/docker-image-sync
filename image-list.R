library(XML)
library("plyr")
library("RCurl")
base_url <- "https://hub.docker.com"

for(page in paste0("https://hub.docker.com/explore/?page=", (1:7)))
{
  base_data<-getURL(page)
  base_data<-htmlParse(base_data)
  data<-getNodeSet(base_data,"//div[@id='app']//ul[@class='large-12 columns no-bullet']//a")
  image_url_list<-laply(data,xmlGetAttr,"href")
  image_url_list<-paste0(base_url,image_url_list)
  
  for(image_url in image_url_list )
  {
    image_data <- getURL(image_url)
    image_data<-htmlParse(image_data)
    image_tag<-getNodeSet(image_data,"//div[@id='app']//div[@class='secondary-contain-to-grid' ]//li[a='Tags']/a")
    image_tag_url <- paste0(base_url, xmlGetAttr(image_tag[[1]],"href"))
    pull_command <- getNodeSet(image_data,"//div[@id='app']//div[@class='row' ]//div/div/div/input[last()]")
    pull_command <- xmlGetAttr(pull_command[[1]],"value")
    print(pull_command)
    pull_command <- strsplit(pull_command, ' ', fixed=TRUE)[[1]][3]
    tag_data<-getURL(image_tag_url)
    tag_data<-htmlParse(tag_data)
    tag_list<-getNodeSet(tag_data,"//div[@id='app']//div[@class='large-12 columns']/div/div/div[position()>1]/div")
    
    tag_list<-laply(tag_list[(1:length(tag_list))%%4 == 1],xmlValue)
    pull_full_command<-paste0(pull_command,":",tag_list)
    write.table(paste0('  - {id:', 1:length(pull_full_command), ', ', 'image: "', pull_full_command, '"}'), file="docker-pull-command.txt", quote=F, append=T, row.names = F, col.names = F)
  }
}
