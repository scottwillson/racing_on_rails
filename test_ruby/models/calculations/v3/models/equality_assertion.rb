# frozen_string_literal: true

# rubocop:disable Style/NilComparison
# rubocop:disable Style/YodaCondition

module EqualityAssertion
  # Test equality, hash, instancend comparison operation
  # instance, equal_instance, equal_instance_2 are separate, equal instances
  # to test that equality is symmetric and transitive
  def assert_equality(instance, equal_instance, equal_instance_2, not_equal_instance)
    assert_eql(instance, equal_instance, equal_instance_2, not_equal_instance)
    assert_equal_method(instance, equal_instance, equal_instance_2, not_equal_instance)
    assert_hash(instance, equal_instance, equal_instance_2, not_equal_instance)

    # consistent
    assert_equal instance, instance
    refute_equal instance, not_equal_instance
  end

  def assert_eql(instance, equal_instance, equal_instance_2, not_equal_instance)
    assert_equal instance, instance
    assert_equal instance, equal_instance
    assert_equal instance, equal_instance_2
    assert_equal equal_instance, instance
    assert_equal equal_instance, equal_instance
    assert_equal equal_instance, equal_instance_2
    assert_equal equal_instance_2, instance
    assert_equal equal_instance_2, equal_instance
    assert_equal equal_instance_2, equal_instance_2
    assert_equal not_equal_instance, not_equal_instance
    refute_equal instance, not_equal_instance
    refute_equal equal_instance, not_equal_instance
    refute_equal equal_instance_2, not_equal_instance
    refute_equal not_equal_instance, instance
    refute_equal not_equal_instance, equal_instance
    refute_equal not_equal_instance, equal_instance_2
    refute_equal instance, nil
    refute_equal not_equal_instance, nil
    refute_equal nil, instance
    refute_equal nil, not_equal_instance
  end

  def assert_equal_method(instance, equal_instance, equal_instance_2, not_equal_instance)
    assert instance.equal?(instance)
    assert equal_instance.equal?(equal_instance)
    assert equal_instance_2.equal?(equal_instance_2)
    assert not_equal_instance.equal?(not_equal_instance)
    refute instance.equal?(equal_instance)
    refute instance.equal?(equal_instance_2)
    refute instance.equal?(not_equal_instance)
    refute instance.equal?(nil)
    refute equal_instance.equal?(instance)
    refute equal_instance.equal?(equal_instance_2)
    refute equal_instance.equal?(not_equal_instance)
    refute equal_instance.equal?(nil)
    refute equal_instance_2.equal?(instance)
    refute equal_instance_2.equal?(equal_instance)
    refute equal_instance_2.equal?(not_equal_instance)
    refute equal_instance_2.equal?(nil)
    refute not_equal_instance.equal?(instance)
    refute not_equal_instance.equal?(equal_instance)
    refute not_equal_instance.equal?(equal_instance_2)
    refute not_equal_instance.equal?(nil)
  end

  def assert_hash(instance, equal_instance, equal_instance_2, not_equal_instance)
    assert_equal instance.hash, instance.hash
    assert_equal instance.hash, equal_instance.hash
    assert_equal instance.hash, equal_instance_2.hash
    assert_equal not_equal_instance.hash, not_equal_instance.hash
    refute_equal instance.hash, not_equal_instance.hash
    refute_equal equal_instance.hash, not_equal_instance.hash
    refute_equal equal_instance_2.hash, not_equal_instance.hash
    refute_equal instance.hash, nil.hash
    refute_equal not_equal_instance.hash, nil.hash
    refute_equal nil.hash, instance.hash
    refute_equal nil.hash, not_equal_instance.hash

    assert instance == instance
    assert instance == equal_instance
    assert instance == equal_instance_2
    assert not_equal_instance == not_equal_instance
    refute instance == not_equal_instance
    refute equal_instance == not_equal_instance
    refute equal_instance_2 == not_equal_instance
    refute instance == nil
    refute not_equal_instance == nil
    refute nil == instance
    refute nil == not_equal_instance
  end

  def assert_comparison(instance, equal_instance, equal_instance_2, not_equal_instance)
    assert_equal 0, instance <=> instance
    assert_equal 0, instance <=> equal_instance
    assert_equal 0, instance <=> equal_instance_2
    assert_equal 0, equal_instance <=> instance
    assert_equal 0, equal_instance <=> equal_instance
    assert_equal 0, equal_instance <=> equal_instance_2
    assert_equal 0, equal_instance_2 <=> instance
    assert_equal 0, equal_instance_2 <=> equal_instance
    assert_equal 0, equal_instance_2 <=> equal_instance_2
    assert_equal 0, not_equal_instance <=> not_equal_instance
    refute_equal 0, instance <=> not_equal_instance
    refute_equal 0, equal_instance <=> not_equal_instance
    refute_equal 0, equal_instance_2 <=> not_equal_instance
    refute_equal 0, not_equal_instance <=> instance
    refute_equal 0, not_equal_instance <=> equal_instance
    refute_equal 0, not_equal_instance <=> equal_instance_2
    refute_equal 0, instance <=> nil
    refute_equal 0, not_equal_instance <=> nil
    refute_equal 0, nil <=> instance
    refute_equal 0, nil <=> not_equal_instance
  end
end

# rubocop:enable Style/NilComparison
# rubocop:enable Style/YodaCondition
