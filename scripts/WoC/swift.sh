rm -f commits identificators result_tmp result

echo retrieving commits ...
zcat /da0_data/play/SwiftthruMaps/c2pJSwift.1.gz | cut -d';' -f1 | ~/lookup/showCnt commit 2 | grep '.*;.*;.*;.*[A-Z]\+-[0-9]\+' | uniq >> commits

echo extracting possible jira issues identificators ...
rm -r identificators
while read -r line; do echo '%s\n' $line | grep -Eo '[A-Z]+-[0-9]+' | head -1 >> identificators; done < commits

echo retrieving project names ...
cat commits | cut -d';' -f1 | ~/lookup/getValues -f c2P | cut -d';' -f2 >> project_names

echo concatenate project names with issue identificators ...
paste project_names identificators -d ";" >> result_tmp

echo reduplicating results ...
cat result_tmp | sort | uniq >> result

echo retrieving github urls ...
for line in $(cat result); do 
	project_name=$(echo "$line" | cut -d';' -f1 | cut -d'_' -f2)
	curl "https://api.github.com/search/repositories?q=$project_name+language:swift&sort=stars&order=desc" 2>/dev/null | jq -r '.items[0].html_url' >> projects_url;
done

echo add urls to result file ...
paste result projects_url -d ";" >> result_with_links