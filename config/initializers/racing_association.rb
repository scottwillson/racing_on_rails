ASSOCIATION = RacingAssociation.first || RacingAssociation.create!

ASSOCIATION_SHORT_NAME = ASSOCIATION.short_name || "CBRA"
ASSOCIATION_DEFAULT_SANCTIONED_BY = ASSOCIATION.default_sanctioned_by || "CBRA"
