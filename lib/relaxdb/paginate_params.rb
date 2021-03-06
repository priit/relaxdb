module RelaxDB

  class PaginateParams
        
    @@params = %w(key startkey startkey_docid endkey endkey_docid count update descending group reduce include_docs)
  
    @@params.each do |param|
      define_method(param.to_sym) do |*val|
        if val.empty?
          instance_variable_get("@#{param}")
        else
          instance_variable_set("@#{param}", val[0])
          # null is meaningful to CouchDB. _set allows us to know that a param has been set, even to nil
          instance_variable_set("@#{param}_set", true)
          self
        end
      end
    end
    
    def initialize
      # If a client hasn't explicitly set descending, set it to the CouchDB default
      @descending = false if @descending.nil?
      # CouchDB defaults reduce to true when a reduce func is present
      @reduce = false
    end
  
    def update(params)
      @order_inverted = params[:descending].nil? ? false : @descending ^ params[:descending]
      @descending = !@descending if @order_inverted

      @endkey = @startkey if @order_inverted
    
      @startkey = params[:startkey] || @startkey
    
      @skip = 1 if params[:startkey]
      
      @startkey_docid = params[:startkey_docid] if params[:startkey_docid]
      @endkey_docid = params[:endkey_docid] if params[:endkey_docid]
    end
  
    def order_inverted?
      @order_inverted
    end
    
    def invalid?
      # Simply because allowing either to be omitted increases the complexity of the paginator
      # This constraint may be removed in future, but don't hold your breath
      @startkey_set && @endkey_set ? nil : "Both startkey and endkey must be set"
    end
    alias error_msg invalid?
      
  end

end