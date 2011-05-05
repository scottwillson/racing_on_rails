page.show "warn"
page.hide "notice"
page["warn_span"].replace_html "Could not delete #{@event.name}: #{@event.errors.full_messages}"
