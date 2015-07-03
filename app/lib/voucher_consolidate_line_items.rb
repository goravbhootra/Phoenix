class VoucherConsolidateLineItems
  def initialize(attributes={})
    # voucher, associated_collection = children that needs to be consolidated, attrib = column on which consolidation will be done eg. product_id, payment_mode_id, consolidate = field to be summed up (let me know if you can think of better term)
    voucher = attributes[:voucher]
    @associated_collection = voucher.send(attributes[:association_name])
    @attrib_id = attributes[:attrib_id]
    @consolidate = attributes[:consolidate]
  end

  def consolidate_with_same_attribute
    # result_hash = line_items.group_by(&:product_id)
    result_hash = {}
    @associated_collection.reject(&:marked_for_destruction?).each do |record|
      if result_hash.key?(record.send(@attrib_id))
        if record.new_record?
          result_hash[record.send(@attrib_id)][@consolidate] += record.send(@consolidate)
          @associated_collection.destroy(record)
        else
          record[@consolidate] += result_hash[record.send(@attrib_id)].send(@consolidate)
          @associated_collection.destroy(result_hash[record.send(@attrib_id)])
          result_hash.delete[record.send(@attrib_id)]
          result_hash[record.send(@attrib_id)] = record
        end
      else
        result_hash[record.send(@attrib_id)] = record
      end
    end
    # puts result_hash
    # puts "here"
    # @associated_collection.select(&:marked_for_destruction?).each { |x| puts x.attributes }
    # puts "deletions"
    # puts @associated_collection.map { |x| [x.attributes, x.marked_for_destruction?] }
  end
end
