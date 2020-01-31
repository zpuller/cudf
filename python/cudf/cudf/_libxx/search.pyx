# Copyright (c) 2020, NVIDIA CORPORATION.

from cudf._libxx.lib cimport *
from cudf._libxx.column cimport Column
from cudf._libxx.table cimport Table
from libcpp.vector cimport vector


def search_sorted(Table table, Table values, side):
    """Find indices where elements should be inserted to maintain order

    Parameters
    ----------
    table : Table
        Table to search in
    values : Table
        Table of values to search for
    side : str {‘left’, ‘right’} optional
        If ‘left’, the index of the first suitable location found is given.
        If ‘right’, return the last such index
    """
    cdef unique_ptr[column] c_result
    cdef vector[order] c_column_order
    cdef vector[null_order] c_null_precedence

    for i in table._num_columns:
        c_column_order.push_back(ASCENDING)
        c_null_precedence.push_back(AFTER)

    if side == 'left':
        with nogil:
            c_result = cpp_lower_bound(
                table.view(),
                values.view(),
                c_column_order,
                c_null_precedence,
            )
    elif side == 'right':
        with nogil:
            c_result = cpp_upper_bound(
                table.view(),
                values.view(),
                c_column_order,
                c_null_precedence,
            )
    return Column.from_unique_ptr(move(c_result))
