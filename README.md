# gx_pipeline
wrapper for the [NCBI FCS pipeline](https://ftp.ncbi.nlm.nih.gov/pub/murphyte/FCS/FCS-genome/fcs_genome_readme.html)

These are wrappers to run the Singularity version of the NCBI FCS_genome pipeline at Sanger

# notes from Terrance Murphy

Hi genome submitters!

Thanks for your prior interest and feedback on NCBI's new FCS tools to identify genome contamination. We've released a new version of both tools, and are moving to a more public beta incorporating a lot of your feedback and ongoing improvements for better sensitivity and specificity.
Based on your prior interest and feedback, I was wondering if you'd be available for a Zoom interview to discuss any issues and challenges that may have come up with getting FCS running and how it's working for you? We have lofty goals for the product and want to make sure we learn as much as we can from your experiences.

## Major developments:
* we've moved to GitHub: [github.com](https://github.com/ncbi/fcs)
* only the two runners are available from GitHub so far, but we are planning to release the code this fall
* FCS-genome is now renamed to FCS-GX. There was a name conflict for "FCS-genome" prompting the change.
* We've released a new screening database for FCS-GX, with better coverage and better cleaning of contaminants. If you need to download those files directly, they're at: [ftp.ncbi.nlm.nih.gov](https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/database/latest/)
* In addition to Docker, both FCS-GX and FCS-adaptor now support Singularity. If you used the earlier FCS-genome Singularity image, we've now moved the sif images to a more public location as described in the documentation, at: [ftp.ncbi.nlm.nih.gov](https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/releases/latest/)
* We've made a lot of improvements to FCS-GX to refine specificity of calls. It's not yet "perfect", but it's getting there.
* We do have a backlog of additional features and bug fixes that we're working on, and we do expect to be releasing updates on a more frequent basis. Watch the GitHub page for new releases, and please either contact us or report issues on GitHub.

If you'd like to share information about the new FCS tools with others, our public announcement is at: [ncbiinsights.ncbi.nlm.nih.gov](https://ncbiinsights.ncbi.nlm.nih.gov/2022/07/28/fcs-beta-tool/)

Best regards,
-Terence Murphy and the FCS development team
Staff Scientist
RefSeq Eukaryotes Product Leader
NCBI/NLM/NIH
