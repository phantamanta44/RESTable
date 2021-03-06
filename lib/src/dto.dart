part of ws_server;

/**
 * Generic stuff
 */

class UptimeResponse {
  int uptime;

  UptimeResponse(this.uptime);
}

/**
 * Table data types
 */

class TableMetaResponse {
  String name;
  List<HeaderCellResponse> header;

  TableMetaResponse(this.name, this.header);

  TableMetaResponse.describing(Table table)
      : this(
            table.name,
            table.header
                .map((h) => new HeaderCellResponse.describing(h))
                .toList());
}

class TableCreationRequest {
  @ApiProperty(required: true)
  String name;
  @ApiProperty(required: true)
  List<HeaderCellRequest> header;
}

class TableInterpRequest {
  @ApiProperty(required: true)
  List<String> tables;
  @ApiProperty(required: true)
  String column;
  @ApiProperty(defaultValue: "")
  String query;
  @ApiProperty(defaultValue: -1)
  int limit;
}

class TableInterpResponse {
  TableMetaResponse info;
  List<List<String>> rows;

  TableInterpResponse(Table table, String query, int limit) {
    info = new TableMetaResponse.describing(table);
    List<dynamic> results;
    if (query.isEmpty) {
      results = table.toList();
    } else {
      Query qTest = new Query.parse(query);
      results = table.where(qTest.matches).toList();
    }
    results = results.map((r) => r.map((w) => w.toString()).toList()).toList();
    rows = limit < 0 ? results : results.sublist(0, min(results.length, limit));
  }
}

/**
 * Row data types
 */

class RowCreationRequest {
  @ApiProperty(required: true)
  List<String> data;
}

class RowMutationRequest {
  @ApiProperty(required: true)
  List<String> data;
}

/**
 * Cell data types
 */

class HeaderCellRequest {
  @ApiProperty(required: true)
  String name;
  @ApiProperty(required: true)
  String dataType;
  String domain;

  HeaderCell toHeaderCell() => new HeaderCell(name, typeByName(dataType),
      domain == null ? domainAcceptAll : new DeserializedDomain.from(domain));
}

class HeaderCellResponse {
  String name;
  String dataType;
  String domain;

  HeaderCellResponse(this.name, this.dataType, this.domain);

  HeaderCellResponse.describing(HeaderCell cell)
      : this(cell.name, cell.type.name, cell.domain.toString());
}
