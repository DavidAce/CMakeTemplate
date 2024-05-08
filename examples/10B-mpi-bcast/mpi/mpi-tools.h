#pragma once
#include "../general/sfinae.h"
#include "mpi-logger.h"
#include <cassert>
#include <complex>
#include <h5pp/details/h5ppFilesystem.h>
#include <h5pp/details/h5ppFormat.h>
#include <mpi.h>
#include <vector>
namespace mpi {

    inline bool on = false;

    struct comm {
        int id   = 0;
        int size = 1;

        template<typename T>
        T get_id() {
            return static_cast<T>(id);
        }
        template<typename T>
        T get_size() {
            return static_cast<T>(size);
        }
    };

    inline comm world;
    void        init();
    void        finalize();
    void        barrier();
    template<typename T>
    [[nodiscard]] constexpr MPI_Datatype get_dtype() noexcept {
        using D               = typename std::decay<T>::type;
        if constexpr(std::is_same_v<D, char>) return MPI_CHAR;
        else if constexpr(std::is_same_v<D, signed char>) return MPI_SIGNED_CHAR;
        else if constexpr(std::is_same_v<D, unsigned char>) return MPI_UNSIGNED_CHAR;
        else if constexpr(std::is_same_v<D, wchar_t>) return MPI_WCHAR;
        else if constexpr(std::is_same_v<D, signed short>) return MPI_SHORT;
        else if constexpr(std::is_same_v<D, unsigned short>) return MPI_UNSIGNED_SHORT;
        else if constexpr(std::is_same_v<D, signed int>) return MPI_INT;
        else if constexpr(std::is_same_v<D, unsigned int>) return MPI_UNSIGNED;
        else if constexpr(std::is_same_v<D, signed long int>) return MPI_LONG;
        else if constexpr(std::is_same_v<D, unsigned long int>) return MPI_UNSIGNED_LONG;
        else if constexpr(std::is_same_v<D, signed long long int>) return MPI_LONG_LONG;
        else if constexpr(std::is_same_v<D, unsigned long long int>) return MPI_UNSIGNED_LONG_LONG;
        else if constexpr(std::is_same_v<D, float>) return MPI_FLOAT;
        else if constexpr(std::is_same_v<D, double>) return MPI_DOUBLE;
        else if constexpr(std::is_same_v<D, long double>) return MPI_LONG_DOUBLE;
        else if constexpr(std::is_same_v<D, std::int8_t>) return MPI_INT8_T;
        else if constexpr(std::is_same_v<D, std::int16_t>) return MPI_INT16_T;
        else if constexpr(std::is_same_v<D, std::int32_t>) return MPI_INT32_T;
        else if constexpr(std::is_same_v<D, std::int64_t>) return MPI_INT64_T;
        else if constexpr(std::is_same_v<D, std::uint8_t>) return MPI_UINT8_T;
        else if constexpr(std::is_same_v<D, std::uint16_t>) return MPI_UINT16_T;
        else if constexpr(std::is_same_v<D, std::uint32_t>) return MPI_UINT32_T;
        else if constexpr(std::is_same_v<D, std::uint64_t>) return MPI_UINT64_T;
        else if constexpr(std::is_same_v<D, bool>) return MPI_C_BOOL;
        else if constexpr(std::is_same_v<D, std::complex<float>>) return MPI_C_COMPLEX;
        else if constexpr(std::is_same_v<D, std::complex<double>>) return MPI_C_DOUBLE_COMPLEX;
        else if constexpr(std::is_same_v<D, std::complex<long double>>) return MPI_C_LONG_DOUBLE_COMPLEX;
        else if constexpr(sfinae::has_Scalar_v<D>) return get_dtype<typename D::Scalar>();
        else if constexpr(sfinae::has_value_type_v<D>) return get_dtype<typename D::value_type>();
        else {
            static_assert(sfinae::invalid_type_v<D>);
        }
        return MPI_DATATYPE_NULL;
    }
    template<typename T>
    [[nodiscard]] void *get_buffer(T &data) {
        if constexpr(sfinae::has_data_v<T>)
            return static_cast<void *>(data.data());
        else if constexpr(std::is_pointer_v<T> or std::is_array_v<T>)
            return static_cast<void *>(data);
        else
            return static_cast<void *>(&data);
    }

    template<typename T>
    [[nodiscard]] const void *get_cbuffer(const T &data) {
        if constexpr(sfinae::has_data_v<T>)
            return static_cast<const void *>(data.data());
        else if constexpr(std::is_pointer_v<T> or std::is_array_v<T>)
            return static_cast<const void *>(data);
        else
            return static_cast<const void *>(&data);
    }

    template<typename T>
    [[nodiscard]] int get_count(T &data) {
        if constexpr(sfinae::has_size_v<T> or std::is_array_v<T>)
            return static_cast<int>(std::size(data));
        else
            return 1;
    }

    template<typename T>
    void send(const T &data, int dst, int tag) {
        if constexpr(sfinae::has_size_v<T>) {
            size_t count = data.size();
            MPI_Send(&count, 1, mpi::get_dtype<size_t>(), dst, 0, MPI_COMM_WORLD);
        }

        MPI_Send(mpi::get_cbuffer(data), mpi::get_count(data), mpi::get_dtype<T>(), dst, tag, MPI_COMM_WORLD);
    }

    template<typename T>
    void recv(T &data, int src, int tag) {
        if constexpr(sfinae::has_size_v<T>) {
            size_t count;
            MPI_Recv(&count, 1, mpi::get_dtype<size_t>(), src, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            if constexpr(sfinae::has_resize_v<T>) data.resize(count);
            if(data.size() < count) throw std::runtime_error(fmt::format("mpi::recv: cointainer size {} < count {}", data.size(), count));
        }
        MPI_Recv(mpi::get_buffer(data), mpi::get_count(data), mpi::get_dtype<T>(), src, tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    template<typename T>
    void sendrecv(const T &send, const T &recv, int src, int dst, int tag) {
        // Start by sending the data size, so we can resize the receiving buffer accordingly
        int count = mpi::get_count(send);
        MPI_Sendrecv_replace(&count, 1, MPI_INT, dst, tag, src, tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        if constexpr(sfinae::has_resize_v<T>) {
            recv.resize(count); // Both containers are now ready to receive
        }
        MPI_Sendrecv(mpi::get_buffer(send), mpi::get_count(send), mpi::get_dtype<T>(), dst, tag, mpi::get_buffer(recv), mpi::get_count(recv),
                     mpi::get_dtype<T>(), src, tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    template<typename T>
    void sendrecv_replace(const T &data, int src, int dst, int tag) {
        // Start by sending the data size, so we can resize the receiving buffer accordingly
        int count = mpi::get_count(data);
        MPI_Sendrecv_replace(&count, 1, MPI_INT, dst, tag, src, tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        if constexpr(sfinae::has_resize_v<T>) {
            data.resize(count); // Should not modify the src container
        }

        MPI_Sendrecv_replace(mpi::get_buffer(data), mpi::get_count(data), mpi::get_dtype<T>(), dst, tag, src, tag, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    }

    void scatter(std::vector<h5pp::fs::path> &data, int srcId);
    void scatter_r(std::vector<h5pp::fs::path> &data, int srcId); // Roundrobin
}