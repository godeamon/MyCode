/*
* represents a 2-division table, used with google chart api or Highchart
*/
public class ChartTable
{
    private Map<String, RowInfo> rowIndex;
    private Map<String, Integer> columnIndex;

    public ChartTable()
    {
        Columns = new List<String>();
        Rows = new List<RowInfo>();
        rowIndex = new Map<String, RowInfo>();
        columnIndex = new Map<String, Integer>();
        Cumulative = false;
    }

    public ChartTable(Boolean isCumulative)
    {
        this();
        this.Cumulative = isCumulative;
    }

    public Boolean Cumulative { get; set; }
    public List<String> Columns { get; set; }
    public List<RowInfo> Rows { get; set; }

    public void addValue(String key, String column, Decimal value)
    {
        CellInfo cell = new CellInfo(value);

        addValue(key, column, cell);
    }

    public void addValue(String key, String column, CellInfo cell)
    {
        Integer columnIndex = getColumnIndex(column);
        if(columnIndex == -1)
        {
            addColumn(column);
            columnIndex = Columns.size() - 1;
        }

        RowInfo foundRow = null;
        if(rowIndex.containsKey(key))
        {
            foundRow = rowIndex.get(key);
        }
        if(foundRow == null)
        {
            foundRow = new RowInfo(key, Columns.size());
            foundRow.Cumulative = Cumulative;
            Rows.add(foundRow);
            rowIndex.put(key, foundRow);
        }

        foundRow.addValue(columnIndex, cell);
    }

    public void addColumn(String columnName)
    {
         if(!columnIndex.containsKey(columnName))
         {
             Columns.add(columnName);
             columnIndex.put(columnName, Columns.size() - 1);
         }
    }

    private Integer getColumnIndex(String columnName)
    {
        if(columnIndex.containsKey(columnName))
        {
            return columnIndex.get(columnName);
        }
        else
        {
            for(Integer i = 0; i < Columns.size(); i++)
            {
                if(Columns[i] == columnName)
                {
                    columnIndex.put(columnName, i);
                    return i;
                }
            }
        }
        return -1;
    }

    public class RowInfo
    {
        public RowInfo(String key)
        {
            this.PrimaryKey = key;
            Cells = new List<CellInfo>();
            Cumulative = false;
            Visible = true;
        }

        public RowInfo(String key, Integer columnCount)
        {
            this(key);
            for(Integer i = 0; i < columnCount; i++)
            {
                Cells.add(new CellInfo(0));
            }
        }

        public Boolean Cumulative { get; set; }
        public String PrimaryKey { get; set; }
        public List<CellInfo> Cells { get ;set; }
        public Boolean Visible { get; set; }

        public void addValue(Integer columnIndex, CellInfo cell)
        {
            if(cell.Hours != null)
            {
                while(Cells.size() <= columnIndex)
                {
                    Cells.add(new CellInfo(0));
                }
                if(Cumulative)
                {
                    Cells[columnIndex].Hours += cell.Hours;
                    Cells[columnIndex].HalfDay = cell.HalfDay;
                    Cells[columnIndex].ImageName = cell.ImageName;
                }
                else
                {
                    Cells[columnIndex] = cell;
                }
            }
        }
    }

    public class CellInfo
    {
        public CellInfo(Decimal hours)
        {
            this.Hours = hours;
            HalfDay = 'NONE';
            this.ImageName = '';
        }

        public CellInfo(Decimal hours, String halfDay, String imageName)
        {
            this.Hours = hours;
            this.HalfDay = halfDay;
            this.ImageName = imageName;
        }

        public Decimal Hours { get; set; }
        public String HalfDay { get; set; }
        public String ImageName { get; set; }
    }
}