import React from "react"
import PropTypes from "prop-types"
class Paragraph extends React.Component {
  render () {
    return (
      <React.Fragment>
        <div class="msg-paragraph">
          <p
            class="msg-par-text"
            dangerouslySetInnerHTML={ this.props.content }
          >
          </p>
          <p class="msg-par-avatar">
            <a href='/'><img src={ this.props.avatar } /></a>
            <br />
            <span class="id-time">{ this.props.who }</span>
            <br />
            <span
              class="id-time"
              title={ this.props.ts }
            >
              { this.props.when } ago
            </span>
          </p>
        </div>
      </React.Fragment>
    );
  }
}

Paragraph.propTypes = {
  avatar: PropTypes.string,
  text: PropTypes.string,
  ts: PropTypes.string,
  when: PropTypes.string,
  who: PropTypes.string,
};
export default Paragraph
