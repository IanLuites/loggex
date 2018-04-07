FROM fluent/fluentd:latest
ADD fluent.conf /fluentd/etc/fluent.conf
EXPOSE 8888 24224
CMD fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
