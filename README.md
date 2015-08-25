This is a quick and dirty script for harvesting metadata from an [OAI-PMH](https://en.wikipedia.org/wiki/Open_Archives_Initiative_Protocol_for_Metadata_Harvesting) enabled repository.

It relies on the `Net::OAI::Harvester` perl module, and is derived from the
`oai-listrecords` script provided in the examples for that library.

Example for harvesting arXiv metadata (honouring flow control directives):

```bash
mkdir arxiv{0,1,2}

# initial sync
./oai-sync.pl --baseURL=http://export.arxiv.org/oai2 --metadataPrefix=arXiv \
              --dumpDir=./arxiv0/

# resume an interrupted sync with the given token
./oai-sync.pl --baseURL=http://export.arxiv.org/oai2 --metadataPrefix=arXiv \
              --dumpDir=./arxiv1/ --resumptionToken='XXXXXX|XXXXXX'

# sync any new changes since the date of the last sync
./oai-sync.pl --baseURL=http://export.arxiv.org/oai2 --metadataPrefix=arXiv \
              --dumpDir=./arxiv2/ --from='2015-03-14'

# split into individual records
for F in ./arxiv*/*.xml; do [ -s $F ] && ./oai-split.sh < $F; done
```
