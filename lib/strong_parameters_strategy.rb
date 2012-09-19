class StrongParametersStrategy < DecentExposure::ActiveRecordWithEagerAttributesStrategy
  def attributes
    get? ? super : controller.send(:"#{name.singularize}_params")
  end
end
