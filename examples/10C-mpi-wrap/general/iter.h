#pragma once
#include <iterator>
namespace iter {
    template<class T>
    class reverse {
        private:
        T &rng;

        public:
        reverse(T &r) noexcept : rng(r) {}

        auto begin() const noexcept {
            using std::end;
            return std::make_reverse_iterator(end(rng));
        }
        auto end() const noexcept {
            using std::begin;
            return std::make_reverse_iterator(begin(rng));
        }
    };

    namespace internal {

        template<class Iterator, bool reverse = false, typename idx_t = std::size_t>
        struct enumerate_iterator {
            using iterator   = Iterator;
            using index_type = idx_t;
            using reference  = typename std::iterator_traits<iterator>::reference;
            using pointer    = typename std::iterator_traits<iterator>::pointer;

            enumerate_iterator(index_type index, iterator iterator) : index(index), iter(iterator) {}
            enumerate_iterator &operator++() {
                if constexpr(reverse)
                    --index;
                else
                    ++index;
                ++iter;
                return *this;
            }

            bool operator!=(const enumerate_iterator &other) const { return iter != other.iter; }

            std::pair<std::reference_wrapper<index_type>, reference> operator*() { return {index, *iter}; }

            private:
            index_type index;
            iterator   iter;
        };

        template<class Iterator, bool reverse = false, typename idx_t = std::size_t>
        struct enumerate_range {
            using index_type = idx_t;
            using iterator   = enumerate_iterator<Iterator, reverse, idx_t>;

            enumerate_range(Iterator first, Iterator last, index_type initial, index_type final) : first(first), last(last), initial(initial), final(final) {}

            iterator begin() const { return iterator(initial, first); }
            iterator end() const { return iterator(final, last); }

            private:
            Iterator   first;
            Iterator   last;
            index_type initial;
            index_type final;
        };
    }

    template<class Iterator>
    decltype(auto) enumerate(Iterator first, Iterator last, std::size_t initial) {
        return internal::enumerate_range<Iterator, false>(first, last, initial);
    }

    template<typename idx_t = std::size_t, class Container>
    decltype(auto) enumerate(Container &content) {
        return internal::enumerate_range<typename Container::iterator, false, idx_t>(std::begin(content), std::end(content), 0,
                                                                                     static_cast<idx_t>(content.size() - 1));
    }

    template<typename idx_t = std::size_t, class Container>
    decltype(auto) enumerate(const Container &content) {
        return internal::enumerate_range<typename Container::const_iterator, false, idx_t>(std::begin(content), std::end(content), 0,
                                                                                           static_cast<idx_t>(content.size() - 1));
    }

    template<class Iterator>
    decltype(auto) enumerate_reverse(Iterator first, Iterator last, std::size_t initial, std::size_t final) {
        return internal::enumerate_range<Iterator, true>(first, last, initial, final);
    }

    template<typename idx_t = std::size_t, class Container>
    decltype(auto) enumerate_reverse(Container &content) {
        return internal::enumerate_range<typename Container::reverse_iterator, true, idx_t>(std::rbegin(content), std::rend(content),
                                                                                            static_cast<idx_t>(content.size() - 1), 0);
    }

    template<typename idx_t = std::size_t, class Container>
    decltype(auto) enumerate_reverse(const Container &content) {
        return internal::enumerate_range<typename Container::const_reverse_iterator, true, idx_t>(std::rbegin(content), std::rend(content),
                                                                                                  static_cast<idx_t>(content.size() - 1), 0);
    }

    enum class order { def, rev };

    template<order o, typename idx_t = std::size_t, class Container>
    decltype(auto) enumerate(Container &content) {
        if constexpr(o == order::rev)
            return internal::enumerate_range<typename Container::reverse_iterator, true, idx_t>(std::rbegin(content), std::rend(content),
                                                                                                static_cast<idx_t>(content.size() - 1), 0);
        else
            return internal::enumerate_range<typename Container::iterator, false, idx_t>(std::begin(content), std::end(content), 0,
                                                                                         static_cast<idx_t>(content.size() - 1));
    }

    template<order o, typename idx_t = std::size_t, class Container>
    decltype(auto) enumerate(const Container &content) {
        if constexpr(o == order::rev)
            return internal::enumerate_range<typename Container::const_reverse_iterator, true, idx_t>(std::rbegin(content), std::rend(content),
                                                                                                      static_cast<idx_t>(content.size() - 1), 0);
        else
            return internal::enumerate_range<typename Container::const_iterator, false, idx_t>(std::begin(content), std::end(content), 0,
                                                                                               static_cast<idx_t>(content.size() - 1));
    }
}