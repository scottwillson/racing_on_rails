# frozen_string_literal: true

NewRelic::Agent.after_fork(force_reconnect: true) if defined? Puma
