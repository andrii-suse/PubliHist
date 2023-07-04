PubliHist - publish with history

The project is a framework for keeping history of published artifacts.

Key features:
- hard links, so duplicates accross different versions do not consume disk space;
- provides folder with aggregation of versions kept (aka LIVE).

Key environment variables:
PH_HIST_DIR - folder where history is kept;
PH_IN_DIR   - folder from where new versions are arriving (by external program);
PH_LIVE_DIR   - folder which aggregates available versions of files;
PH_LIVE_COUNT - how many versions to show in live (defaul all);
PH_RETAIN_COUNT - how may versions are kept (default 2).

Available scripts overview:
ph_hist   - syncs new version from IN_DIR into HIST_DIR.
ph_retain - delete old versions (according to RETAIN variables).
ph_live   - refresh LIVE with available versions in HIST.
ph_sync   - syncs HIST tree to a new location (and honor hard links).

