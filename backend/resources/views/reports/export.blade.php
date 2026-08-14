<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>{{ $title }}</title>
    <style>
        body { font-family: sans-serif; font-size: 12px; color: #111827; }
        h1 { font-size: 18px; color: #374151; margin-bottom: 4px; }
        .subtitle { color: #6B7280; margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #E5E7EB; padding: 8px; text-align: left; }
        th { background-color: #374151; color: #FFFFFF; text-transform: uppercase; font-size: 10px; }
        tr:nth-child(even) { background-color: #F9FAFB; }
    </style>
</head>
<body>
    <h1>Amana Wallet - {{ $title }}</h1>
    <div class="subtitle">{{ $from }} to {{ $to }} &middot; Generated {{ now()->toDateTimeString() }}</div>

    <table>
        <thead>
            <tr>
                @foreach ($columns as $column)
                    <th>{{ str_replace('_', ' ', $column) }}</th>
                @endforeach
            </tr>
        </thead>
        <tbody>
            @foreach ($rows as $row)
                <tr>
                    @foreach ($row as $value)
                        <td>{{ $value }}</td>
                    @endforeach
                </tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>